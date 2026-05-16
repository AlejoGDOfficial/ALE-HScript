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
        scope.define('Math', Math);
    }

    public function execute(expr:Expr, ?optionalScope:Scope):Dynamic
    {
        return switch (expr)
        {
            case EProgram(stmts):
                trace(expr);

                var result:Dynamic = null;

                try
                {
                    for (stmt in stmts)
                        result = execute(stmt);
                } catch (signal:ReturnSignal) {
                    result = signal.value;
                }

                result;

            case ECall(obj, args):
                Reflect.callMethod(null, execute(obj), [for (arg in args) execute(arg)]);

            case EVarRef(name):
                scope.get(name);

            case EType(path):
                Type.resolveClass(path.join('.'));

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