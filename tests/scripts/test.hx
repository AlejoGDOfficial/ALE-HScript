final oso:String = 'oso';

trace('donde');

function oso(?val:Float = 10):String
{
    trace(val);
}

oso();

var map:haxe.ds.StringMap = new haxe.ds.StringMap<String>();

map.set('oso', 'donde');

trace(map);

return 10;