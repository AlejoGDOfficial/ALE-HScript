package;

import haxe.ds.StringMap;

class Interp extends scripting.haxe.ScriptBasic
{
    public var superInstance(default, set):Dynamic;
    function set_superInstance(value:Dynamic):Dynamic
    {
        superInstance = value;

        scope.superInstance = superInstance;

        return superInstance;
    }

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

    function setProperty(expr:Expr, value:Dynamic):Void
    {
        switch (expr)
        {
            case EVar(name):
                scope.assign(name, value);
            case EProperty(objExpr, property):
                Reflect.setProperty(evaluate(objExpr), property, value);
            default:
                error();
        }
    }

    function executeStatement(statement:Stmt):Dynamic
    {
        return switch (statement)
        {
            case SVar(name, val):
                scope.define(name, evaluate(val));

                null;
            case SAssign(name, val):
                switch (val)
                {
                    case EProperty(_, __):
                        setProperty(val, evaluate(val));
                    default:
                        scope.assign(name, evaluate(val));
                }
                
                null;
            case SReturn(val):
                evaluate(val);
            case SBlock(stmts):
                executeBlock(stmts);
            default:
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

    function evaluate(expr:Expr):Dynamic
    {
        return switch (expr)
        {
            case EString(str):
                str;
            case ENumber(num):
                num;
            case EVar(name):
                scope.get(name);
            case EProperty(name, property):
                Reflect.getProperty(evaluate(name), property);
            case EBinOp(left, op, right):
                final l = evaluate(left);

                final r = evaluate(right);

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
        }
    }
}