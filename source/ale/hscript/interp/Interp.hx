package ale.hscript.interp;

import ale.hscript.parser.Expr;
import ale.hscript.lexer.Token;

import ale.hscript.utils.TypeList;

class Interp
{
    public final name:String;

    public var scope:Scope;

    public var scriptPackage(default, set):Array<String> = [];
    function set_scriptPackage(value:Array<String>):Array<String>
    {
        if (scriptPackage.length > 0)
            return scriptPackage;

        return scriptPackage = value;
    }

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

            case EPackage(pack):
                scriptPackage = pack;

            case EImport(cls, wildcard, nick):
                final jointCls:String = cls.join('.');

                if (wildcard)
                {
                    if (TypeList.list.exists(jointCls))
                        for (cls in TypeList.list[jointCls])
                        {
                            final type = Type.resolveClass(jointCls + '.' + cls);

                            if (type != null)
                                scope.define(cls, type);
                        }
                } else {
                    scope.define(nick ?? cls[cls.length - 1], Type.resolveClass(jointCls));
                }

                null;

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
                Type.createInstance(execute(cls), [for (arg in args) execute(arg)]);

            case EIdent(id):
                var result = null;

                if (scope.exists(id[0]))
                {
                    result = scope.get(id[0]);

                    if (id.length > 1)
                        for (i in 1...id.length)
                            result = Reflect.getProperty(result, id[i]);
                } else {
                    result = Type.resolveClass(id.join('.')) ?? Type.resolveClass(scriptPackage.concat(id).join('.'));
                }

                if (result == null)
                    throw 'Unknown Variable: ' + id.join('.');

                result;

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