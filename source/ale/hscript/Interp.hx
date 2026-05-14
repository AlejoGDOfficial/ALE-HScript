package ale.hscript;

import ale.hscript.Types.Stmt;
import ale.hscript.Types.Expr;

class Interp
{
    public var scope:Scope;

    public function new()
    {
        scope = new Scope();

        scope.define('trace', (e) -> {
            trace(e);
        });
    }

    public function execute(statement:Stmt):Dynamic
    {
        switch (statement)
        {
            case SVar(id, val):
                scope.define(id, val);
            case SReturn(val):
                return val;
            case SFunction(id, args, block):
                scope.define(id, Reflect.makeVarArgs((params:Array<Dynamic>) -> {
                    final newScope:Scope = new Scope(scope);

                    for (index => arg in args)
                        newScope.define(arg.name, params[index] ?? eval(arg.value));

                    return executeBlock(switch (block)
                    {
                        case SBlock(stmts):
                            stmts;
                        default:
                            [];
                    }, newScope);
                }));
            case SBlock(stmts):
                executeBlock(stmts, new Scope(scope));
            case SCall(obj, args):
                final func = eval(obj);

                if (Reflect.isFunction(func))
                    Reflect.callMethod(this, func, [for (arg in args) eval(arg)]);
            default:
        }

        return null;
    }

    function executeBlock(stmts:Array<Stmt>, scope:Scope)
    {
        final previous = this.scope;
        
        this.scope = scope;

        var result:Dynamic = null;

        for (stmt in stmts)
        {
            result = execute(stmt);

            if (result != null)
                break;
        }

        this.scope = previous;

        return result;
    }

    function eval(expr:Expr):Dynamic
    {
        return switch (expr)
        {
            case ENull:
                null;
            case ETrue:
                true;
            case EFalse:
                false;
            case ENumber(value):
                value;
            case EString(value):
                value;
            case EProperty(obj, property):
                if (obj == null)
                    scope.get(property);
                else
                    null;
            default:
                null;
        }
    }
}