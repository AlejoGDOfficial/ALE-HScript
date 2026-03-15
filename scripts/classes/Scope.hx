package;

import haxe.ds.StringMap;

class Scope
{
    public var parent:Scope;

    public var superInstance:Dynamic;

    public var variables:StringMap<Dynamic> = new StringMap();

    public function new(?parent:Scope)
    {
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
        else if (parent != null)
            return parent.get(name);
        else if (superInstance != null)
            return Reflect.getProperty(superInstance, name);

        return null;
    }

    public function assign(name:String, value:Dynamic)
    {
        if (variables.exists(name))
            variables.set(name, value);
        else if (parent != null)
            parent.assign(name, value);
        else if (superInstance != null)
            Reflect.setProperty(superInstance, name, value);
    }
}