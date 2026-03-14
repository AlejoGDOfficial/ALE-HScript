package;

import Token;
import Stmt;
import Expr;

class Parser extends scripting.haxe.ScriptBasic
{
    public final tokens:Array<Token>;
    
    public function new(tokens:Array<Token>)
    {
        super();
        
        this.tokens = tokens;
    }

    var pos:Int = 0;

    function advance():Token
    {
        return tokens[pos++];
    }

    function isEnd():Bool
    {
        return pos < tokens.length;
    }

    function parse()
    {
        final result:Array<Stmt> = [];

        while (!isEnd())
        {
            final stmt:Stmt = parseStatement();

            if (stmt != null)
                result.push(stmt);
        }

        debugTrace(result);

        return [];
    }

    function parseStatement():Stmt
    {
        return switch (advance())
        {

        }
    }
}