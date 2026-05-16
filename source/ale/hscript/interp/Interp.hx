package ale.hscript.interp;

import ale.hscript.parser.Expr;
import ale.hscript.lexer.Token;

import ale.hscript.utils.TypeList;

class Interp
{
    public final name:String;

    public var scope:Scope;

    public final imports:Map<String, Class<Dynamic>> = [];

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
        scope.define('Math', Math);
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

            case EImport(module, wildcard, nick):
                if (wildcard)
                {
                    if (TypeList.list.exists(module))
                    {
                        for (cls in TypeList.list.get(module))
                        {
                            final type = Type.resolveClass(module + '.' + cls);

                            if (type != null)
                                imports[cls] = type;
                        }
                    }
                } else {
                    imports[nick ?? module.split('.').pop()] = Type.resolveClass(module);
                }

                null;

            case ENew(type, args):
                Type.createInstance(execute(type), [for (arg in args) execute(arg)]);

            case EBlock(stmts):
                final previous:Scope = scope;
                
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

            case ESet(name, value):
                final val:Dynamic = execute(value);
                
                scope.set(name, val);

                val;

            case ESetField(obj, name, value):
                final val:Dynamic = execute(value);

                Reflect.setProperty(execute(obj), name, val);

                val;

            case ECall(obj, args):
                Reflect.callMethod(null, execute(obj), [for (arg in args) execute(arg)]);

            case EVar(name, value):
                final val:Dynamic = execute(value);

                scope.define(name, val);

                val;

            case EVarRef(name):
                scope.get(name);

            case EFunction(name, args, block):
                scope.define(name, Reflect.makeVarArgs(
                    (params:Array<Dynamic>) -> {
                        final newScope:Scope = new Scope(scope);

                        for (i => arg in args)
                            newScope.define(arg.name, params[i] ?? execute(arg.value));

                        execute(block, newScope);
                    }
                ));

                null;

            case EType(module):
                Type.resolveClass(module) ?? imports[module];

            case EField(obj, field):
                Reflect.getProperty(execute(obj), field);

            case EBinOp(left, op, right):
                final l = execute(left);
                final r = execute(right);

                if (l == null || r == null)
                    return null;

                untyped switch (op)
                {
                    case TPlus:
                        l + r;

                    case TStar:
                        l * r;

                    case TSlash:
                        l / r;

                    case TPercent:
                        l % r;

                    case TDoubleEqual:
                        l == r;

                    case TExclamationEqual:
                        l != r;

                    case TLess:
                        l < r;

                    case TGreater:
                        l > r;

                    case TLessEqual:
                        l <= r;

                    case TGreaterEqual:
                        l >= r;

                    case TDoubleAmpersand:
                        l && r;

                    case TDoublePipe:
                        l || r;

                    case TAmpersand:
                        l & r;

                    case TPipe:
                        l | r;

                    case TCaret:
                        l ^ r;

                    case TDoubleLess:
                        l << r;

                    case TDoubleGreater:
                        l >> r;

                    case TTripleGreater:
                        l >>> r;

                    default:
                        null;
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