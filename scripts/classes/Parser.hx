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

    function peekBack():Token
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

    function tokenError(?got:String)
    {
        throw 'Unexpected Token: ' + (got ?? peekBack());
    }
    
    public function parse():Array<Stmt>
    {
        final result:Array<Stmt> = [];

        while (pos < tokens.length)
        {
            final statement:Stmt = parseStatement();

            if (statement != null)
                result.push(statement);
        }
        
        return result;
    }

    function parseStatement():Stmt
    {
        return switch (peek())
        {
            case TIdent(id):
                switch (id)
                {
                    case 'var':
                        parseVar();
                    case 'return':
                        parseReturn();
                    default:
                        switch (peekNext())
                        {
                            case TEqual:                                
                                parseAssign();
                            default:
                                pos++;

                                null;
                        }
                }
            case TLBrace:
                parseBlock();
            default:
                pos++;

                null;
        }
    }

    function parseBlock():Stmt
    {
        advance();

        final result:Array<Stmt> = [];

        while (pos < tokens.length && switch (peek()) {case TRBrace: false; default: true;})
        {
            final statement:Stmt = parseStatement();

            if (statement != null)
                result.push(statement);
        }

        switch (advance())
        {
            case TRBrace:
            default:
                tokenError();
        }

        return Stmt.SBlock(result);
    }

    function parseVar()
    {
        advance();

        final name:String = switch (advance())
        {
            case TIdent(id):
                id;
            default:
                tokenError();
        };

        switch (advance())
        {
            case TColon:
                switch (advance())
                {
                    case TIdent(id):
                    default:
                        tokenError();
                }

                switch (advance())
                {
                    case TEqual:
                    default:
                        tokenError();
                }
            case TEqual:
            default:
                tokenError();
        }

        final value:Expr = parseExpr();

        advance();

        return Stmt.SVar(name, value);
    }

    function parseAssign():Stmt
    {
        final name:String = switch (advance())
        {
            case TIdent(id):
                id;
            default:
                null;
        }

        advance();

        return Stmt.SAssign(name, parseExpr());
    }

    function parseReturn():Stmt
    {
        advance();

        final expr:Expr = parseExpr();

        advance();

        return Stmt.SReturn(expr);
    }

    function parseExpr():Expr
    {
        return parseAddSub();
    }

    function parseAddSub():Expr
    {
        var expr:Expr = parseMulDiv();

        while (pos < tokens.length)
        {
            switch (peek())
            {
                case TOp(op):
                    if (['+', '-'].contains(op))
                    {
                        advance();

                        expr = Expr.EBinary(expr, op, parseMulDiv());
                    } else {
                        return expr;
                    }
                default:
                    return expr;
            }
        }

        return expr;
    }

    function parseMulDiv():Expr
    {
        var expr:Expr = parsePrimary();

        while (pos < tokens.length)
        {
            switch (peek())
            {
                case TOp(op):
                    if (['*', '/', '%'].contains(op))
                    {
                        advance();

                        expr = Expr.EBinary(expr, op, parsePrimary());
                    } else {
                        return expr;
                    }
                default:
                    return expr;
            }
        }

        return expr;
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
                        tokenError();
                }

                expr;
            default:
                tokenError();
        }
    }
}