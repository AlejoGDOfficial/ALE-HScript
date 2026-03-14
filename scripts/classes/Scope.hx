package;

import haxe.ds.StringMap;

class Scope extends scripting.haxe.ScriptBasic
{
    public var parent:Scope;

    public var variables:StringMap<Dynamic> = new StringMap();

    public function new(?parent:Scope)
    {
        super();

        this.parent = parent;
    }

    public function define(name:String, value:Dynamic)
    {
        variables.set(name, value);
    }

    public function get(name:String):Dynamic
    {
        if (variables.exists(name))
            return variables.get(name);

        if (parent != null)
            return parent.get(name);

        return null;
    }

    public function assign(name:String, value:Dynamic)
    {
        if (variables.exists(name))
            variables.set(name, value);
        else if (parent != null)
            parent.assign(name, value);
    }
}