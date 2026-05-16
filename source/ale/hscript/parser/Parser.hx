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
                            result = EType(pathVer);

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
                final name = switch (advance())
                {
                    case TIdent(n):
                        n;

                    default:
                        error();

                        null;
                }

                final args:Array<FunctionArgument> = parseFunctionArguments();

                parseOptionalType();

                EFunction(name, args, parseBlock());

            case TLeftBrace:
                index--;

                parseBlock();

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

    function parseBlock():Expr
    {
        final result:Array<Expr> = [];

        expect(TLeftBrace);

        while (!isEnd() && peek() != TRightBrace)
        {
            final res:Expr = parseExpr();

            if (res != null)
                result.push(res);
        }

        expect(TRightBrace);

        return EBlock(result);
    }

    function parseArguments():Array<Expr>
    {
        final result:Array<Expr> = [];

        expect(TLeftParen);

        while (!isEnd() && peek() != TRightParen)
        {
            result.push(parseExpr());
            
            if (peek() == TComma)
                advance();
            else
                break;
        }

        expect(TRightParen);

        return result;
    }

    function parseFunctionArguments():Array<FunctionArgument>
    {
        final result:Array<FunctionArgument> = [];

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

            var value:Dynamic = null;

            if (peek() == TEqual)
            {
                advance();

                value = parseExpr();
            }

            result.push({name: name, value: value});

            if (peek() == TComma)
                advance();
            else
                break;
        }

        expect(TRightParen);

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

    function parseType():Expr
    {
        var typeName:String = '';

        switch (advance())
        {
            case TIdent(name):
                typeName += name;

                while (!isEnd() && peek() == TDot)
                {
                    advance();

                    final name:String = switch (advance())
                    {
                        case TIdent(n):
                            n;

                        default:
                            error();

                            null;
                    };

                    typeName += '.' + name;
                }
                
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

        return EType(typeName);
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