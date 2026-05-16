package;

import haxe.ds.StringMap;

final oso:String = 'oso';

trace('donde');

function oso(?val:Float = 10):String
{
    trace(val);
}

oso();

var map:StringMap = new StringMap<String>();

map.set('oso', 'donde');

trace(map);

return 10;