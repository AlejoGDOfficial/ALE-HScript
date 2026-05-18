package ale.hscript.parser;

import ale.hscript.lexer.Token;

class ClassParser extends Parser
{
    override public function parse():Expr
    {
        final result:Array<Expr> = [];

        while (!isEnd())
        {
            final res:Expr = parseClass();

            if (res != null)
                result.push(res);
        }

        return EProgram(result);
    }

    function parseClass():Expr
    {
        return switch (peek())
        {
            case TPackage, TImport, TSemicolon:
                parseExpr();

            case TClass:
                expect(TClass);

                switch (advance())
                {
                    case TIdent(_):

                    default:
                        error();

                        null;
                }

                expect(TLeftBrace);

                final result:Array<Expr> = [];

                while (!isEnd() && peek() != TRightBrace)
                {
                    result.push(switch (peek())
                    {
                        case TVar, TFunction:
                            parseExpr();

                        default:
                            error();

                            null;
                    });
                }

                expect(TRightBrace);

                EProgram(result);

            default:
                error(true);

                null;
        }
    }
}