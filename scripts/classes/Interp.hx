package;

import haxe.ds.StringMap;

class Interp
{
    public var superInstance(default, set):Dynamic;
    function set_superInstance(value:Dynamic):Dynamic
    {
        superInstance = value;

        scope.superInstance = superInstance;

        return superInstance;
    }

    public function new() {}

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
            case EVar(id):
                scope.assign(id, value);
            case EProperty(object, id):
                Reflect.setProperty(evaluate(object), id, value);
            default:
        }
    }

    function executeStatement(statement:Stmt):Dynamic
    {
        return switch (statement)
        {
            case SVar(name, val):
                scope.define(name, evaluate(val));

                null;
            case SAssign(object, value):
                setProperty(object, evaluate(value));
                
                null;
            case SReturn(val):
                evaluate(val);
            case SBlock(stmts):
                executeBlock(statement);
            case SIf(condition, block, elseIf):
                if (evaluate(condition))
                    executeBlock(block);
                else if (elseIf != null)
                    executeStatement(elseIf);

                null;
            default:
                null;
        }
    }

    function executeBlock(block:Stmt):Dynamic
    {
        switch (block)
        {
            case SBlock(statements):
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
            default:
        }

        return null;
    }

    function evaluate(expr:Expr):Dynamic
    {
        return switch (expr)
        {
            case ENull:
                null;
            case ETrue:
                true;
            case EFalse:
                false;
            case EString(str):
                str;
            case ENumber(num):
                num;
            case EVar(name):
                scope.get(name);
            case EProperty(name, property):
                Reflect.getProperty(evaluate(name), property);
            case EBinOp(left, op, right):
                final l:Dynamic = evaluate(left);

                final r:Dynamic = evaluate(right);

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
            case EUnOp(op, right):
                final r:Dynamic = evaluate(right);

                switch (op)
                {
                    case '-':
                        -r;
                    case '!':
                        !r;
                    default:
                        null;
                }
            default:
                null;
        }
    }
}