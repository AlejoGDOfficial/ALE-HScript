package;

import Token;
import Stmt;
import Expr;

class Parser
{
    public final tokens:Array<Token>;
    
    public function new(tokens:Array<Token>)
    {
        this.tokens = tokens;
    }
    
    var operatorsPrecedence:Array<Array<String>> = [
        ['||'],
        ['&&'],
        ['==', '!='],
        ['>', '<', '>=', '<='],
        ['&', '^', '|'],
        ['<<', '>>', '>>>'],
        ['+', '-'],
        ['*', '/', '%']
    ];

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

    function error()
    {
        throw 'Unexpected Token: ' + peekLast();
    }

    public function parse()
    {
        final result:Array<Stmt> = [];

        while (!isEnd())
        {
            final stmt:Stmt = parseStatement();

            if (stmt != null)
                result.push(stmt);
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
                        advance();

                        parseVariable();
                    case 'return':
                        advance();

                        parseReturn();
                    case 'if':
                        advance();

                        parseIf();
                    default:
                        final expr:Expr = parseExpr();

                        switch (advance())
                        {
                            case TEqual:
                                final result:Stmt = Stmt.SAssign(expr, parseExpr());

                                semicolon();

                                result;
                            default:
                                null;
                        }
                }
            case TLBrace:            
                advance();

                parseBlock();
            default:
                advance();

                error();
                
                null;
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

                null;
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

    function parseReturn():Stmt
    {
        final expr:Expr = parseExpr();

        semicolon();

        return Stmt.SReturn(expr);
    }

    function parseIf():Stmt
    {
        switch (advance())
        {
            case TLParen:
            default:
                error();
        }

        final condition:Expr = parseExpr();

        switch (advance())
        {
            case TRParen:
            default:
                error();
        }

        final block:Stmt = switch (advance())
        {
            case TLBrace:
                parseBlock();
            default:
                null;
        }

        var elseBlock:Stmt = null;

        switch (advance())
        {
            case TIdent(id):
                switch (id)
                {
                    case 'else':
                        switch (advance())
                        {
                            case TLBrace:
                                elseBlock = parseBlock();
                            default:
                                error();
                        }
                    default:
                }
            default:
        }

        return Stmt.SIf(condition, block, elseBlock);
    }

    function parseProperty(expr:Expr):Expr
    {
        while (true)
        {
            switch (peek())
            {
                case TDot:
                    advance();

                    switch (advance())
                    {
                        case TIdent(id):
                            expr = Expr.EProperty(expr, id);
                        default:
                            error();
                    }
                default:
                    return expr;
            }
        }
    }

    function parseBlock():Stmt
    {
        final result:Array<Stmt> = [];

        while (!isEnd() && switch (peek()) { case TRBrace: false; default: true; })
        {
            final stmt:Stmt = parseStatement();

            if (stmt != null)
                result.push(stmt);
        }

        switch (advance())
        {
            case TRBrace:
            default:
                error();
        }

        return Stmt.SBlock(result);
    }

    function parseExpr():Expr
    {
        return parseBinOps();
    }

    function parseBinOps(?level:Int):Expr
    {
        level ??= 0;

        final nextFunc = level >= operatorsPrecedence.length ? () -> parseUnary() : () -> parseBinOps(level + 1);

        var expr:Expr = nextFunc();

        while (!isEnd())
        {
            switch (peek())
            {
                case TOp(op):
                    if (level < operatorsPrecedence.length && operatorsPrecedence[level].contains(op))
                    {
                        advance();

                        expr = Expr.EBinOp(expr, op, nextFunc());
                    } else {
                        break;
                    }
                default:
                    break;
            }
        }

        return expr;
    }

    function parseUnary():Expr
    {
        switch (peek())
        {
            case TOp(op):
                if (['-', '!'].contains(op))
                {
                    advance();

                    return Expr.EUnOp(op, parseUnary());
                }
            default:
        }

        return parsePrimary();
    }

    function parsePrimary():Expr
    {
        var expr:Expr = switch (advance())
        {
            case TString(str):
                Expr.EString(str);
            case TNumber(num):
                Expr.ENumber(num);
            case TIdent(id):
                switch (id)
                {
                    case 'true':
                        Expr.ETrue;
                    case 'false':
                        Expr.EFalse;
                    default:
                        Expr.EVar(id);
                }
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

                null;
        }

        expr = parseProperty(expr);

        return expr;
    }
}