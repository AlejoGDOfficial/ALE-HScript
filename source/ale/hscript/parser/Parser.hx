package ale.hscript.parser;

import ale.hscript.lexer.Token;

class Parser
{
    public final tokens:Array<Token>;

    public function new(tokens:Array<Token>)
        this.tokens = tokens;

    var index:Int = 0;

    function peek():Token
        return tokens[index];

    function peekLast():Token
        return tokens[index - 1];

    function peekNext():Token
        return tokens[index + 1];

    function advance():Token
        return tokens[index++];

    function isEnd():Bool
        return index >= tokens.length;

    function error(?cur:Bool = false):Bool
    {
        throw 'Unexpected Token: ' + (cur ? peek() : peekLast());

        return false;
    }

    function semicolon()
        if (!advance().match(TSemicolon))
            error();

    public function parse():Expr
    {
        final result:Array<Expr> = [];

        while (!isEnd())
        {
            final toPush:Expr = parseStatement();

            if (toPush != null)
                result.push(toPush);
        }
        
        return EBlock(result);
    }

    public function parseStatement():Expr
    {
        return switch (peek())
        {
            case TVar:
                parseVar();

            default:
                advance();

                null;
        }
    }

    function parseVar():Expr
    {
        advance();

        return null;
    }
}