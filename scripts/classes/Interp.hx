package;

import haxe.ds.StringMap;

class Interp extends scripting.haxe.ScriptBasic
{
    var scope:Scope = new Scope();

    public function execute(ast:Array<Stmt>):Dynamic
    {
        for (stmt in ast)
        {
            final result:Dynamic = executeStatement(stmt);

            if (result != null)
                return result;
        }

        return null;
    }

    function executeStatement(stmt:Stmt):Dynamic
    {
        return switch (stmt)
        {
            case SVar(name, value):
                scope.define(name, eval(value));

                null;
            case SAssign(name, value):
                scope.assign(name, eval(value));

                null;
            case SReturn(expr):
                eval(expr);
            case SBlock(stmts):
                executeBlock(stmts);
        }
    }

    function executeBlock(statements:Array<Stmt>):Dynamic
    {
        final previous:Scope = scope;

        scope = new Scope(scope);

        for (stmt in statements)
        {
            final result:Dynamic = executeStatement(stmt);

            if (result != null)
            {
                scope = previous;

                return result;
            }
        }

        scope = previous;

        return null;
    }

    function eval(expr:Expr):Dynamic
    {
        return switch (expr)
        {
            case EString(str):
                str;
            case EVar(name):
                scope.get(name);
            case ENumber(num):
                num;
            case EBinary(left, op, right):
                final l = eval(left);

                final r = eval(right);
                
                switch (op)
                {
                    case '+':
                        l + r;
                    case '-':
                        l - r;
                    case '*':
                        l * r;
                    case '/':
                        l / r;
                    case '%':
                        l % r;
                    case '==':
                        l == r;
                    case '!=':
                        l != r;
                    case '>':
                        l > r;
                    case '<':
                        l < r;
                    case '>=':
                        l >= r;
                    case '<=':
                        l <= r;
                    case '&&':
                        l && r;
                    case '||':
                        l || r;
                    case '&':
                        l & r;
                    case '|':
                        l | r;
                    case '^':
                        l ^ r;
                    case '<<':
                        l << r;
                    case '>>':
                        l >> r;
                    case '>>>':
                        l >>> r;
                    default:
                        null;
                }
            default:
                null;
        }
    }
}