package;

import Token;

class Tokenizer
{
    final identReg:EReg = ~/^[A-Za-z_][A-Za-z0-9_]*$/;
    final numberReg:EReg = ~/^[0-9.]+$/;
    final spaceReg:EReg = ~/\s+/;

    var operators:Array<String> = ['+', '-', '*', '/', '%', '==', '!=', '>', '<', '>=', '<=', '&&', '||', '&', '|', '^', '<<', '>>', '>>>', '!'];

    public final content:String;

    var pos:Int = 0;

    public function new(content:String)
    {
        operators.sort((a, b) -> b.length - a.length);

        this.content = content;
    }

    inline function isEnd():Bool
    {
        return pos >= content.length;
    }

    inline function peek():String
    {
        return content.charAt(pos);
    }

    inline function advance():String
    {
        return content.charAt(pos++);
    }

    function readIdent():String
    {
        var str:String = '';

        while (!isEnd() && identReg.match(peek()))
            str += advance();

        return str;
    }

    function readString():String
    {
        var str:String = '';

        final curString:String = advance();

        while (!isEnd() && peek() != curString)
            str += advance();

        advance();

        return str;
    }

    function readNumber():Float
    {
        var str:String = '';

        while (!isEnd() && numberReg.match(peek()))
            str += advance();

        return Std.parseFloat(str);
    }

    public function tokenize():Array<Token>
    {
        var result:Array<Token> = [];

        while (!isEnd())
        {
            var cur = peek();

            var foundOp:Bool = false;

            for (op in operators)
            {
                if (content.substr(pos, op.length) == op)
                {
                    result.push(Token.TOp(op));

                    pos += op.length;

                    foundOp = true;
                    
                    break;
                }
            }

            if (foundOp)
                continue;

            switch (cur)
            {
                case '.':
                    advance();

                    result.push(Token.TDot);
                case '(':
                    advance();

                    result.push(Token.TLParen);
                case ')':
                    advance();

                    result.push(Token.TRParen);
                case '{':
                    advance();

                    result.push(Token.TLBrace);
                case '}':
                    advance();

                    result.push(Token.TRBrace);
                case ':':
                    advance();

                    result.push(Token.TColon);

                case ';':
                    advance();

                    result.push(Token.TSemiColon);

                case '=':
                    advance();

                    result.push(Token.TEqual);

                case '\'', '"':
                    result.push(Token.TString(readString()));

                default:
                    if (spaceReg.match(cur))
                    {
                        advance();

                        continue;
                    }

                    if (identReg.match(cur))
                        result.push(Token.TIdent(readIdent()));
                    else if (numberReg.match(cur))
                        result.push(Token.TNumber(readNumber()));
                    else
                        advance();
            }
        }

        return result;
    }
}