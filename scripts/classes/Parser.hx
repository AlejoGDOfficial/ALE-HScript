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

    function isEnd()
    {
        return pos < tokens.length;
    }

    function parse()
    {
        final result:Array<Stmt> = [];

        while (!isEnd())
        {
            pos++;
        }

        debugTrace(result);

        return [];
    }
}