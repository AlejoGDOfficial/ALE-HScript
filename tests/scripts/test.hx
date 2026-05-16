import haxe.ds.StringMap as OsoMap;

final oso:String = 'oso';

trace('donde');

function oso(?val:Float = 10):String
{
    trace(val);
}

oso();

var map:OsoMap = new OsoMap<String>();

map.set('oso', 'donde');

trace(map);

return 10;