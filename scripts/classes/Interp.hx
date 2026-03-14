package;

import haxe.ds.StringMap;

class Interp extends scripting.haxe.ScriptBasic
{
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

    function executeStatement(statement:Stmt):Dynamic
    {
        switch (statement)
        {
            case SVar(name, val):
                scope.assign(name, evaluate(val));

                null;
        }
    }
}