package ale.hscript;

import ale.hscript.Types.Token;

class Lexer
{
    public function new()
        operators.sort((a, b) -> b.length - a.length);

    final identReg:EReg = ~/^[A-Za-z_][A-Za-z0-9_]*$/;
    final numberReg:EReg = ~/^[0-9.]+$/;
    final spaceReg:EReg = ~/\s+/;
    
    final operators:Array<String> = [
        '+',
        '-',
        '*',
        '/',
        '%',
        '==',
        '!=',
        '>',
        '<',
        '>=',
        '<=',
        '&&',
        '||',
        '&',
        '|',
        '^',
        '<<',
        '>>',
        '>>>',
        '!'
    ];

    final simpleTokens:Map<String, Token> = [
        '.' => TDot,
        '(' => TLParen,
        ')' => TRParen,
        '{' => TLBrace,
        '}' => TRBrace,
        ':' => TColon,
        ';' => TSemiColon,
        '=' => TEqual,
        '?' => TQuestion
    ];

    public var content:String = '';

    var pos:Int = 0;

    inline function isEnd():Bool
        return pos >= content.length;

    inline function peek():String
        return content.charAt(pos);

    inline function advance():String
        return content.charAt(pos++);

    function readWhile(reg:EReg):String
    {
        var str = '';

        while (!isEnd() && reg.match(peek()))
            str += advance();

        return str;
    }

    function readIdent():String
        return readWhile(identReg);

    function readString():String
    {
        var quote = advance();

        var str = '';

        while (!isEnd() && peek() != quote)
            str += advance();

        advance();

        return str;
    }

    function readNumber():Float
        return Std.parseFloat(readWhile(numberReg));

    final idents:Map<String, Token> = [
        'var' => TVar,
        'final' => TFinal,
        'class' => TClass,
        'enum' => TEnum,
        'typedef' => TTypedef,
        'abstract' => TAbstract,
        'function' => TFunction,
        'package' => TPackage,
        'import' => TImport,
        'as' => TAs,
        'null' => TNull,
        'true' => TTrue,
        'false' => TFalse
    ];

    public function tokenize():Array<Token>
    {
        var result:Array<Token> = [];

        while (!isEnd())
        {
            var cur = peek();

            var foundOp = false;

            for (op in operators)
            {
                if (content.substr(pos, op.length) == op)
                {
                    result.push(TOp(op));

                    pos += op.length;

                    foundOp = true;

                    break;
                }
            }

            if (foundOp)
                continue;

            if (simpleTokens.exists(cur))
            {
                advance();

                result.push(simpleTokens.get(cur));

                continue;
            }

            if (cur == '\'' || cur == '"')
            {
                result.push(TString(readString()));

                continue;
            }

            if (spaceReg.match(cur))
            {
                advance();
                
                continue;
            }

            if (identReg.match(cur))
            {
                final ident:String = readIdent();

                result.push(idents[ident] ?? TIdent(ident));
            } else if (numberReg.match(cur)) {
                result.push(TNumber(readNumber()));
            } else {
                advance();
            }
        }

        return result;
    }
}