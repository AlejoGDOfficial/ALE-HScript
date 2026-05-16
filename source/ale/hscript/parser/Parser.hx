package ale.hscript.parser;

import ale.hscript.lexer.Token;

import haxe.ds.ArraySort;

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
            final res:Expr = parseExpr();

            if (res != null)
                result.push(res);
        }

        return EProgram(result);
    }

    function parseExpr(precedence:Precedence = NONE):Expr
    {
        var left = parsePrefix();

        while (!isEnd() && Std.int(precedence) < Std.int(getPrecedence(peek())))
            left = parsePostfix(left);

        return left;
    }

    function parsePrefix():Expr
    {
        return switch (advance())
        {
            case TNumber(val):
                ENumber(val);

            case TString(val):
                EString(val);

            case TTrue:
                ETrue;

            case TFalse:
                EFalse;

            case TNull:
                ENull;

            case TIdent(name):
                var pathVer:String = name;

                var result:Expr = EVarRef(name);

                var shouldContinue:Bool = peek() == TDot;

                while (!isEnd() && shouldContinue)
                {
                    advance();

                    switch (advance())
                    {
                        case TIdent(n):
                            if (pathVer != null)
                                pathVer += (pathVer.length > 0 ? '.' : '') + n;
                        
                            result = EField(result, n);

                        default:
                            error();

                            null;
                    }

                    if (pathVer != null)
                    {
                        final type = Type.resolveClass(pathVer);

                        if (type != null)
                        {
                            result = EType(pathVer.split('.'));

                            pathVer = null;
                        }
                    }

                    shouldContinue = switch (peek())
                    {
                        case TDot:
                            true;

                        default:
                            false;
                    }
                }

                result;

            case TLeftParen:
                final result = parseExpr();

                expect(TRightParen);

                result;
            
            case TExclamation, TDoublePlus, TDoubleMinus:
                EPrefix(peekLast(), parseExpr(UNARY));

            case TFunction:
                // parseFunction();

                null;

            case TNew:
                // ENew(parseTypePath(), parseArguments());

                null;

            default:
                null;
        }
    }

    function parsePostfix(left:Expr):Expr
    {
        return switch (peek())
        {
            case TLeftParen:
                ECall(left, parseArguments());

            case TEqual:
                advance();

                switch (left)
                {
                    case EVarRef(name):
                        ESet(left, name, parseExpr());

                    default:
                        error(true);

                        null;
                }

            case TPlus, TMinus, TStar, TSlash, TPercent, TDoubleEqual, TExclamationEqual, TLess, TGreater, TLessEqual, TGreaterEqual, TDoubleAmpersand, TDoublePipe, TAmpersand, TPipe, TCaret, TDoubleLess, TDoubleGreater, TTripleGreater:
                final op = advance();

                final right = parseExpr(getPrecedence(op));

                EBinOp(left, op, right);

            default:
                left;
        }
    }

    function parseArguments():Array<Expr>
    {
        final result:Array<Expr> = [];

        expect(TLeftParen);

        var shouldContinue:Bool = peek() != TRightParen;

        while (!isEnd() && shouldContinue)
        {
            result.push(parseExpr());

            shouldContinue = switch (peek())
            {
                case TComma:
                    advance();

                    true;

                default:
                    false;
            }
        }

        expect(TRightParen);

        return result;
    }

    function getPrecedence(op:Token):Precedence
    {
        return switch (op)
        {
            case TEqual, TPlusEqual, TMinusEqual, TStarEqual, TSlashEqual, TPercentEqual, TDoubleLessEqual, TDoubleGreaterEqual, TTripleGreaterEqual, TAmpersandEqual, TPipeEqual, TCaretEqual:
                ASSIGNMENT;

            case TQuestion, TColon:
                TERNARY;

            case TDoublePipe:
                OR;

            case TDoubleAmpersand:
                AND;

            case TPipe:
                BIT_OR;

            case TCaret:
                BIT_XOR;

            case TAmpersand:
                BIT_AND;

            case TDoubleEqual, TExclamationEqual:
                EQUALITY;

            case TLess, TGreater, TLessEqual, TGreaterEqual:
                COMPARISON;

            case TDoubleLess, TDoubleGreater, TTripleGreater:
                SHIFT;

            case TPlus, TMinus:
                TERM;

            case TStar, TSlash, TPercent:
                FACTOR;

            case TExclamation, TDoublePlus, TDoubleMinus:
                UNARY;

            case TLeftParen:
                CALL;

            case TDot:
                MEMBER;

            default:
                NONE;
        }
    }
}