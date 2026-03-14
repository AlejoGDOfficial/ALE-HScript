package;

import Token;

class Tokenizer extends scripting.haxe.ScriptBasic
{
    final identReg:EReg = ~/^[A-Za-z_][A-Za-z0-9_]*$/;
    
    final spaceReg = ~/\s+/;

    public final content:String;

    var pos:Int = 0;

    public function new(content:String)
    {
        super();

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
        var str = '';

        while (!isEnd() && identReg.match(peek()))
            str += advance();

        return str;
    }

    function readString():String
    {
        var str = '';

        advance();

        while (!isEnd() && peek() != '\'')
            str += advance();

        advance();

        return str;
    }

    public function tokenize():Array<Token>
    {
        var result:Array<Token> = [];

        while (!isEnd())
        {
            var cur = peek();

            switch (cur)
            {
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
                    else
                        advance();
            }
        }

        return result;
    }
}