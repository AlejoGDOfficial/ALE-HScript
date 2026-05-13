final oso:String = 'oso';

function osoFunc(?oso:String)
{
    oso += 'donde';

    trace('Scope: ' + oso);
}

osoFunc('donde tu ta');

trace(oso);