package ale.hscript.interp;

import ale.hscript.parser.Expr;
import ale.hscript.lexer.Token;

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

    public function execute(expr:Expr):Dynamic
    {
        #if hscriptBenchmark
        final startTime:Float = Timer.stamp();
        #end

        final result:Dynamic = eval(expr);

        #if hscriptBenchmark
        final endTime:Float = Timer.stamp();
        
        Config.BENCHMARK_HANDLER('Interp', endTime - startTime);
        #end

        return result;
    }

    public function eval(expr:Expr, ?optionalScope:Scope):Dynamic
    {
        return switch (expr)
        {
            case EProgram(stmts):
                var result:Dynamic = null;

                try
                {
                    for (stmt in stmts)
                        result = eval(stmt);
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
                        result = eval(stmt);
                } catch (signal:ReturnSignal) {
                    result = signal.value;
                }

                scope = previous;

                result;

            case EVar(name, value):
                final value = eval(value);

                scope.define(name, value);

                value;

            case EFunction(name, args, block):
                final func = Reflect.makeVarArgs(
                    function (params:Array<Dynamic>)
                    {
                        final newScope:Scope = new Scope(scope);

                        for (index => arg in args)
                            newScope.define(arg.name, eval(params[index] ?? arg.value));

                        return eval(block, newScope);
                    }
                );

                scope.define(name, func);

                func;

            case ECall(obj, args):
                final func = eval(obj);

                if (Reflect.isFunction(func))
                    Reflect.callMethod(this, func, [for (arg in args) eval(arg)]);
                else
                    null;

            case EInstance(cls, args):
                Type.createInstance(eval(cls), [for (arg in args) eval(arg)]);

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
                throw new ReturnSignal(eval(value));

            default:
                null;
        }
    }
}