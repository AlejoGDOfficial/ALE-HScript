package;

import haxe.ds.StringMap;

class Interp extends scripting.haxe.ScriptBasic
{
    public var variables:StringMap<Dynamic> = new StringMap();

    public function execute(ast:Array<Stmt>):Dynamic
    {
        for (stmt in ast)
        {
            switch (stmt)
            {
                case SVar(name, value):
                    variables.set(name, eval(value));
                case SReturn(value):
                    return eval(value);
            }
        }

        return null;
    }

    function eval(expr:Expr):Dynamic
    {
        return switch (expr)
        {
            case EString(str):
                str;
            case EVar(name):
                variables.get(name);
        }
    }
}