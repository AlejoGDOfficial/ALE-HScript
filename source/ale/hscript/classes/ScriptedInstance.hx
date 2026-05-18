package ale.hscript.classes;

import ale.hscript.interp.Interp;

import ale.hscript.ScriptedClass;

class ScriptedInstance
{
    public var interp:Interp;

    public function new(cls:ScriptedClass, ?args:Array<Dynamic>)
    {
        interp = new Interp(cls.name);

        interp.execute(cls.program);

        trace(args);

        Reflect.callMethod(null, interp.scope.get('new'), args);
    }
}