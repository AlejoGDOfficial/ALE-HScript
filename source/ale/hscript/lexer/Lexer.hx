package ale.hscript.lexer;

class Lexer
{
    final content:String;

    public function new(content:String)
        this.content = content;

    var index:Int = 0;

    inline function isEnd():Bool
        return index >= content.length;

    inline function peek(offset:Int = 0):Int
        return StringTools.fastCodeAt(content, index + offset);

    inline function advance():Int
        return StringTools.fastCodeAt(content, index++);

    inline function match(char:String):Bool
    {
        if (peek() != StringTools.fastCodeAt(char, 0))
            return false;

        index++;

        return true;
    }

    inline function isDigit(char:Int):Bool
        return char >= '0'.code && char <= '9'.code;

    inline function isIdentStart(char:Int):Bool
        return (char >= 'a'.code && char <= 'z'.code) || (char >= 'A'.code && char <= 'Z'.code) || char == '_'.code;

    inline function isIdent(char:Int):Bool
        return isIdentStart(char) || isDigit(char);

    function readIdent():String
    {
        final start = index;

        while (!isEnd() && isIdent(peek()))
            index++;

        return content.substring(start, index);
    }

    function readString():String
    {
        final quote = advance();

        final start = index;

        while (!isEnd() && peek() != quote)
            index++;

        final str = content.substring(start, index);

        if (!isEnd())
            index++;

        return str;
    }

    function readNumber():Float
    {
        final start = index;

        while (!isEnd() && isDigit(peek()))
            index++;

        if (!isEnd() && peek() == '.'.code)
        {
            index++;

            while (!isEnd() && isDigit(peek()))
                index++;
        }

        return Std.parseFloat(content.substring(start, index));
    }

    function readOperator():Token
    {
        switch (advance())
        {
            case '!'.code:
                if (match('='))
                    return TExclamationEqual;

                return TExclamation;

            case '='.code:
                if (match('='))
                    return TDoubleEqual;

                return TEqual;

            case '+'.code:
                if (match('+'))
                    return TDoublePlus;

                if (match('='))
                    return TPlusEqual;

                return TPlus;

            case '-'.code:
                if (match('-'))
                    return TDoubleMinus;

                if (match('='))
                    return TMinusEqual;

                if (match('>'))
                    return TArrow;

                return TMinus;

            case '*'.code:
                if (match('='))
                    return TStarEqual;

                return TStar;

            case '/'.code:
                if (match('='))
                    return TSlashEqual;

                return TSlash;

            case '%'.code:
                if (match('='))
                    return TPercentEqual;

                return TPercent;

            case '>'.code:
                if (match('='))
                    return TGreaterEqual;

                return TGreater;

            case '<'.code:
                if (match('='))
                    return TLessEqual;

                return TLess;

            case '&'.code:
                if (match('&'))
                    return TDoubleAmpersand;

                return TAmpersand;

            case '|'.code:
                if (match('|'))
                    return TDoublePipe;

                return TPipe;

            default:
                throw 'Unexpected Character: ' + content.charAt(index);

                return null;
        }
    }

    public function tokenize():Array<Token>
    {
        final result:Array<Token> = [];

        while (!isEnd())
        {
            final cur = peek();

            final curString:String = content.charAt(index);

            switch (curString)
            {
                case ' ', '\n', '\r', '\t':
                {
                    index++;

                    continue;
                }

                case '"', '\'':
                {
                    result.push(TString(readString()));

                    continue;
                }
            }

            if (TokenUtil.symbolFromString.exists(curString))
            {
                index++;

                result.push(TokenUtil.symbolFromString[curString]);

                continue;
            }

            if (isIdentStart(cur))
            {
                final ident = readIdent();

                result.push(TokenUtil.keywordFromString[ident] ?? TIdent(ident));

                continue;
            }

            if (isDigit(cur))
            {
                result.push(TNumber(readNumber()));

                continue;
            }

            result.push(readOperator());
        }

        return result;
    }
}