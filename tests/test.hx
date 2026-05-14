var typedOso:Array<Oso -> (Donde, Tu) -> Ta -> Oso -> Tengo<Hambre<(Oso, Donde) -> Ta>>>;

final oso:String = 'oso';

function osoFunc(?oso:String, ?donde:String = 'oso'):String
{
    oso += 'donde';

    trace('Scope: ' + oso);
}

osoFunc('donde tu ta');

trace(oso);