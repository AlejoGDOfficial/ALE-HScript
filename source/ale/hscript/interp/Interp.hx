package ale.hscript.interp;

import ale.hscript.parser.Expr;
import ale.hscript.lexer.Token;
import ale.hscript.Config;

class Interp
{
    public final name:String;

    public var scope:Scope;

    public function new(?name:String)
    {
        this.name = name ?? Config.INTERP_NAME;

        scope = new Scope();

        scope.define('trace', (e) -> Sys.println(this.name + ': ' + e));
    }

    public function execute(expr:Expr, ?optionalScope:Scope):Dynamic
    {
        return switch (expr)
        {
            case EProgram(stmts):
                var result:Dynamic = null;

                try
                {
                    for (stmt in stmts)
                        result = execute(stmt);
                } catch (signal:ReturnSignal) {
                    result = signal.value;
                }

                result;

            case EBlock(stmts):
                final previous = scope;
                
                scope = optionalScope ?? new Scope(scope);

                var result:Dynamic = null;

                try
                {
                    for (stmt in stmts)
                        result = execute(stmt);
                } catch (signal:ReturnSignal) {
                    result = signal.value;
                }

                scope = previous;

                result;

            case EVar(name, value):
                final value = execute(value);

                scope.define(name, value);

                value;

            case EFunction(name, args, block):
                final func = Reflect.makeVarArgs(
                    function (params:Array<Dynamic>)
                    {
                        final newScope:Scope = new Scope(scope);

                        for (index => arg in args)
                            newScope.define(arg.name, execute(params[index] ?? arg.value));

                        return execute(block, newScope);
                    }
                );

                scope.define(name, func);

                func;

            case ECall(obj, args):
                final func = execute(obj);

                if (Reflect.isFunction(func))
                    Reflect.callMethod(this, func, [for (arg in args) execute(arg)]);
                else
                    null;

            case EInstance(cls, args):
                final newClass = execute(cls);

                Type.createInstance(newClass, [for (arg in args) execute(arg)]);

            case EIdent(id):
                final cls = Type.resolveClass(id.join('.'));

                if (cls == null)
                {
                    var obj = scope.get(id[0]);

                    if (obj == null)
                        throw 'Unknown Variable: ' + id[0];

                    if (id.length > 1)
                        for (i in 1...id.length)
                            obj = Reflect.getProperty(obj, id[i]);

                    obj;

                } else {
                    cls;
                }

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

            case EReturn(value):
                throw new ReturnSignal(execute(value));

            default:
                null;
        }
    }
}