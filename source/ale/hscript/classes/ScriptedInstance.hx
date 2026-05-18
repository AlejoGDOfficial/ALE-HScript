package ale.hscript.classes;

import ale.hscript.interp.Interp;

import ale.hscript.ScriptedClass;

class ScriptedInstance
{
    public final scriptedClass:ScriptedClass;

    public var interp:Interp;

    public function new(cls:ScriptedClass, ?args:Array<Dynamic>)
    {
        scriptedClass = cls;

        interp = new Interp(cls.name);

        interp.execute(cls.program);

        Reflect.callMethod(null, interp.scope.get('new'), args);
    }

    function toString():String
        return scriptedClass.path;
}