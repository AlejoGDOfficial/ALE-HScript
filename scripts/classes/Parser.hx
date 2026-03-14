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

    function semicolon()
    {
        switch (advance())
        {
            case TSemiColon:
            default:
                error();
        }
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
        final name:String = switch (advance())
        {
            case TIdent(id):
                id;
            default:
                error();
        }

        var value:Null<Expr> = Expr.ENull;

        switch (peek())
        {
            case TColon:
                advance();

                switch (advance())
                {
                    case TIdent(_):
                    default:
                        error();
                }
            default:
        }

        switch (advance())
        {
            case TEqual:
                value = parseExpr();
                        
                semicolon();
            case TSemiColon:
            default:
                error();
        }

        return Stmt.SVar(name, value);
    }

    function parseExpr():Expr
    {
        return parseAddSub();
    }

    function parseBinOp(exprFunc:Void -> Expr, ops:Array<String>):Expr
    {
        var expr:Expr = exprFunc();

        while (!isEnd())
        {
            switch (peek())
            {
                case TOp(op):
                    if (ops.contains(op))
                    {
                        advance();

                        expr = Expr.EBinary(expr, op, exprFunc());
                    } else {
                        break;
                    }
                default:
                    break;
            }
        }

        return expr;
    }
    
    function parseAddSub():Expr
    {
        return parseBinOp(parseMulDiv, ['+', '-']);
    }
    
    function parseMulDiv():Expr
    {
        return parseBinOp(parsePrimary, ['*', '/', '%']);
    }

    function parsePrimary():Expr
    {
        return switch (advance())
        {
            case TString(str):
                Expr.EString(str);
            case TNumber(num):
                Expr.ENumber(num);
            case TIdent(id):
                Expr.EVar(id);
            case TLParen:
                final expr:Expr = parseExpr();

                switch (advance())
                {
                    case TRParen:
                    default:
                        error();
                }

                expr;
            default:
                error();
        }
    }
}