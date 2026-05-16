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

    function expect(val:Token)
        if (advance() != val)
            throw 'Expected Token: ' + val;

    public function parse():Expr
    {
        final result:Array<Expr> = [];

        while (!isEnd())
        {
            final toPush:Expr = parseStatement();

            if (toPush != null)
                result.push(toPush);
        }
        
        return EProgram(result);
    }

    public function parseStatement():Expr
    {
        return switch (peek())
        {
            case TVar, TFinal:
                parseVar();

            case TFunction:
                parseFunction();

            case TReturn:
                advance();

                final result:Expr = parseExpr();

                expect(TSemicolon);
                
                EReturn(result);

            case TIdent(_):
                final variable:Expr = parseExpr();

                switch (peek())
                {
                    case TSemicolon:
                        advance();

                        null;

                    case TLeftParen:
                        parseCall(variable);

                    default:
                        error();

                        null;
                }

            default:
                advance();

                null;
        }
    }

    function parseVar():Expr
    {
        advance();

        final name:String = switch (advance())
        {
            case TIdent(n):
                n;
            
            default:
                error();

                null;
        }

        parseOptionalType();

        final value:Expr = switch (peek())
        {
            case TEqual:
                advance();

                parseExpr();

            default:
                null;
        }
        
        return EVar(name, value);
    }

    function parseFunction():Expr
    {
        advance();

        final name:String = switch (advance())
        {
            case TIdent(n):
                n;

            default:
                error();

                null;
        }

        final args:Array<FunctionArgument> = [];

        expect(TLeftParen);

        while (!isEnd() && peek() != TRightParen)
        {
            if (peek() == TQuestion)
                advance();

            final name:String = switch (advance())
            {
                case TIdent(n):
                    n;

                default:
                    error();

                    null;
            }

            parseOptionalType();

            final value:Dynamic = switch (peek())
            {
                case TEqual:
                    advance();

                    parsePrimary();
                
                default:
                    null;
            }

            args.push({name: name, value: value});
        }

        expect(TRightParen);

        parseOptionalType();

        return EFunction(name, args, parseBlock());
    }

    function parseBlock():Expr
    {
        final result:Array<Expr> = [];

        expect(TLeftBrace);

        while (!isEnd() && peek() != TRightBrace)
        {
            final stmt:Expr = parseStatement();

            if (stmt != null)
                result.push(stmt);
        }

        expect(TRightBrace);

        return EBlock(result);
    }

    
    function parseCall(obj:Expr):Expr
    {
        final args:Array<Expr> = [];

        expect(TLeftParen);

        while (!isEnd() && peek() != TRightParen)
            args.push(parseExpr());

        expect(TRightParen);

        return ECall(obj, args);
    }


    function parseExpr():Expr
    {
        return parsePrimitive();
    }

    function parsePrimitive():Expr
    {
        return switch (peek())
        {
            case TIdent(_):
                parseProperty();

            default:
                parsePrimary();
        }
    }

    function parsePrimary():Expr
    {
        return switch (advance())
        {
            case TNull:
                ENull;
            
            case TTrue:
                ETrue;

            case TFalse:
                EFalse;

            case TNumber(value):
                ENumber(value);

            case TString(value):
                EString(value);

            default:
                error();

                null;
        }
    }

    function parseProperty():Expr
    {
        var result:Expr = EProperty(null,
            switch (advance())
            {
                case TIdent(id):
                    id;

                default:
                    error();

                    null;
            }
        );

        while (!isEnd() && peek() == TDot)
        {
            advance();

            result = EProperty(result,
                switch (advance())
                {
                    case TIdent(id):
                        id;

                    default:
                        error();

                        null;
                }
            );
        }

        return result;
    }


    function parseOptionalType()
    {
        if (peek() == TColon)
        {
            advance();

            parseType();
        }
    }    

    function parseType()
    {
        switch (advance())
        {
            case TIdent(_):

            case TLeftParen:
                var total:Int = 0;
            
                while (!isEnd() && !peek().match(TRightParen))
                {                    
                    if (total > 0 && !advance().match(TComma))
                        error();

                    parseType();

                    total++;
                }

                expect(TRightParen);

                expect(TArrow);

                parseType();

            default:
                error();
        }

        switch (peek())
        {
            case TLess:
                advance();

                parseType();

                expect(TGreater);

            case TArrow:
                advance();
                
                parseType();
                
            default:
        }
    }
}