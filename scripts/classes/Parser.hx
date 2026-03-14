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

    function peek():Token
    {
        return tokens[pos];
    }

    function peekLast():Token
    {
        return tokens[pos - 1];
    }

    function peekNext():Token
    {
        return tokens[pos + 1];
    }

    function advance():Token
    {
        return tokens[pos++];
    }

    function isEnd():Bool
    {
        return pos >= tokens.length;
    }

    function error():Bool
    {
        throw 'Unexpected Token: ' + peekLast();
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
            case TIdent(id):
                switch (id)
                {
                    case 'var':
                        parseVariable();
                    default:
                }
            default:
        }
    }

    function parseVariable():Stmt
    {
        final name:String = switch (peek())
        {
            case TIdent(id):
                id;
            default:
                error();
        }

        debugTrace(name);
    }
}