package ale.hscript.parser;

import ale.hscript.lexer.Token;

class Parser
{
    public final tokens:Array<Token>;

    public function new(tokens:Array<Token>)
        this.tokens = tokens;

    public function parse():Expr
    {
        final result:Array<Expr> = [];

        return EBlock(result);
    }
}