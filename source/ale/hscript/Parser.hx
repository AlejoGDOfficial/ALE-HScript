package ale.hscript;

import ale.hscript.Types;

import haxe.Constraints.IMap;

class Parser
{
    public var tokens:Array<Token> = [];

    public function new() {}

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
    {
        switch (advance())
        {
            case TSemiColon:
            default:
                error();
        }
    }

    public function parse():Array<Stmt>
    {
        final result:Array<Stmt> = [];

        while (!isEnd())
        {
            final toPush:Stmt = parseStatement();

            if (toPush != null)
                result.push(toPush);
        }

        trace(result);

        return result;
    }

    function parseStatement():Stmt
    {
        return switch (peek())
        {
            case TVar, TFinal:
                parseVar();
            case TFunction:
                parseFunction();
            default:
                advance();
                
                null;
        }
    }

    function parseFunction():Stmt
    {
        advance();

        final funcName:String = switch (advance())
        {
            case TIdent(ident):
                ident;
            default:
                error();

                null;
        }

        final args:Array<FunctionArgument> = parseFunctionArgs();

        final block:Stmt = parseBlock();

        return SFunction(funcName, args, block);
    }

    function parseFunctionArgs():Array<FunctionArgument>
    {
        final result:Array<FunctionArgument> = [];

        if (!advance().match(TLParen))
            error();

        while (!isEnd() && !peek().match(TRParen))
        {
            if (result.length >= 1)
                if (!advance().match(TCommma))
                    error();

            final res:FunctionArgument = {
                name: '',
                value: null
            };

            switch (peek())
            {
                case TQuestion:
                    advance();
                case TIdent(_):
                default:
            }

            res.name = switch (advance())
            {
                case TIdent(id):
                    id;
                default:
                    error();

                    null;
            }

            switch (advance())
            {
                case TColon:
                    parseType();
                default:
                    error();
            }

            if (peek().match(TEqual))
            {
                advance();

                res.value = parsePrimitive();
            }

            result.push(res);
        }
        
        if (!advance().match(TRParen))
            error();

        if (peek().match(TColon))
        {
            advance();

            if (!advance().match(TIdent(_)))
                error();
        }

        return result;
    }

    function parseBlock():Stmt
    {
        final result:Array<Stmt> = [];

        if (!advance().match(TLBrace))
            error();

        while (!isEnd() && !peek().match(TRBrace))
        {
            final stmt:Stmt = parseStatement();

            if (stmt != null)
                result.push(stmt);
        }

        if (!advance().match(TRBrace))
            error();

        return SBlock(result);
    }

    function parseVar():Stmt
    {
        advance();

        final varName:String = switch (advance())
        {
            case TIdent(ident):
                ident;
            default:
                error();

                null;
        }

        switch (advance())
        {
            case TColon:
                parseType();
            default:
                error();
        }

        switch (peek())
        {
            case TEqual:
                advance();
            case TSemiColon:
                advance();

                return SVar(varName, ENull);
            default:
                error();
        }

        final value:Dynamic = parseExpr();

        semicolon();

        return SVar(varName, value);
    }

    function parseExpr():Expr
    {
        return parsePrimitive();
    }

    function parseType()
    {
        switch (advance())
        {
            case TIdent(_):
            case TLParen:
                var total:Int = 0;
            
                while (!isEnd() && !peek().match(TRParen))
                {                    
                    if (total > 0)
                        if (!advance().match(TCommma))
                            error();

                    parseType();

                    total++;
                }

                if (!advance().match(TRParen))
                    error();

                if (!advance().match(TArrow))
                    error();

                parseType();
            default:
                error();
        }

        switch (peek())
        {
            case TOp('<'):
                advance();

                parseType();

                if (!advance().match(TOp('>')))
                    error();
            case TArrow:
                advance();
                
                parseType();
            default:
        }
    }

    function parsePrimitive():Expr
    {
        return switch (advance())
        {
            case TNull:
                ENull;
            case TTrue:
                ETrue;
            case TFalse:
                EFalse;
            case TNumber(val):
                ENumber(val);
            case TString(val):
                EString(val);
            default:
                error();

                null;
        }
    }
}