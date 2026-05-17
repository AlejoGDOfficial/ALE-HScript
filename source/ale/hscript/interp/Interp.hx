package ale.hscript.interp;

import ale.hscript.parser.Expr;

import ale.hscript.lexer.TokenUtil;
import ale.hscript.lexer.Token;

import ale.hscript.utils.TypeList;

class Interp
{
    public final name:String;

    public var scope:Scope;

    public var scriptPackage:String = null;

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
                trace(stmts);

                var result = null;

                try
                {
                    for (stmt in stmts)
                        result = execute(stmt);
                } catch (signal:ReturnSignal) {
                    result = signal.value;
                }

                result;
            
            case EPackage(pack):
                scriptPackage = pack;

                null;

            case EImport(module, wildcard, nick):
                if (wildcard)
                {
                    if (TypeList.list.exists(module))
                    {
                        for (cls in TypeList.list.get(module))
                        {
                            final type = Type.resolveClass(module + '.' + cls);

                            if (type != null)
                                scope.define(cls, type);
                        }
                    }
                } else {
                    scope.define(nick ?? module.split('.').pop(), Type.resolveClass(module));
                }

                null;

            case ENew(type, args):
                Type.createInstance(execute(type), [for (arg in args) execute(arg)]);

            case EBlock(stmts):
                final previous:Scope = scope;
                
                scope = optionalScope ?? new Scope(scope);

                var result = null;

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
                scope.set(name, execute(value));

            case ESetField(obj, name, value):
                final val = execute(value);
            
                Reflect.setProperty(execute(obj), name, val);

                val;

            case ECall(obj, args):
                Reflect.callMethod(null, execute(obj), [for (arg in args) execute(arg)]);

            case EVar(name, value):
                scope.define(name, execute(value));

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
                Type.resolveClass(module) ?? Type.resolveClass((scriptPackage == null ? '' : scriptPackage + '.') + module) ?? scope.get(module);

            case EField(obj, field):
                Reflect.getProperty(execute(obj), field);

            case EBinOp(left, op, right):
                final l = execute(left);

                final r = execute(right);

                if (l == null || r == null)
                    return null;

                final result = untyped switch (op)
                {
                    case TPlus, TPlusEqual:
                        l + r;

                    case TStar, TStarEqual:
                        l * r;

                    case TSlash, TSlashEqual:
                        l / r;

                    case TPercent, TPercentEqual:
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

                    case TAmpersand, TAmpersandEqual:
                        l & r;

                    case TPipe, TPipeEqual:
                        l | r;

                    case TCaret, TCaretEqual:
                        l ^ r;

                    case TDoubleLess, TDoubleLessEqual:
                        l << r;

                    case TDoubleGreater, TDoubleGreaterEqual:
                        l >> r;

                    case TTripleGreater, TTripleGreaterEqual:
                        l >>> r;

                    default:
                        null;
                }

                if (TokenUtil.assignOps.contains(op))
                {
                    switch (left)
                    {
                        case EVarRef(name):
                            scope.set(name, result);

                        case EField(obj, name):
                            Reflect.setProperty(execute(obj), name, result);

                        default:
                    }
                }

                result;

            case EPrefix(op, right):
                final r = execute(right);

                if (r == null)
                    return null;

                untyped switch (op)
                {
                    case TExclamation:
                        !r;

                    case TMinus:
                        -r;

                    case TDoublePlus, TDoubleMinus:
                        final func:Float -> Float = (val) -> val + (op == TDoubleMinus ? -1 : 1);

                        switch (right)
                        {
                            case EVarRef(name):
                                scope.set(name, func(scope.get(name)));

                            case EField(obj, name):
                                final obj = execute(obj);

                                final val = func(Reflect.getProperty(obj, name));

                                Reflect.setProperty(obj, name, val);

                                val;

                            default:
                                null;
                        }

                    default:
                        null;
                }

            case EPostfix(left, op):
                final l = execute(left);

                if (l == null)
                    return null;

                untyped switch (op)
                {
                    case TDoublePlus, TDoubleMinus:
                        final func:Float -> Float = (val) -> val + (op == TDoubleMinus ? -1 : 1);

                        switch (left)
                        {
                            case EVarRef(name):
                                final oldVal = scope.get(name);

                                scope.set(name, func(oldVal));

                                oldVal;

                            case EField(obj, name):
                                final obj = execute(obj);

                                final oldVal = Reflect.getProperty(obj, name);

                                Reflect.setProperty(obj, name, func(oldVal));

                                oldVal;

                            default:
                                null;
                        }

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