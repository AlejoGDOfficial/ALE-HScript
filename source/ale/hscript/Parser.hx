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

    function error()
        throw 'Unexpected Token: ' + peekLast();

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

        return result;
    }

    function parseBlock():Stmt
    {
        return SBlock([]);
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
                switch (advance())
                {
                    case TIdent(_):

                    default:
                        error();
                }
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