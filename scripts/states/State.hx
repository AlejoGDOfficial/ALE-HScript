package;

CoolUtil.resizeGame(500, 500, false);

MobileAPI.setOrientation('portrait');

add(new FlxSprite().makeGraphic(10, 10));

function onHotReloadingConfig()
{
    for (file in Paths.readDirectory('scripts/classes'))
    {
        addHotReloadingFile('scripts/classes/' + file);
    }
    
    addHotReloadingFile('script.hx');
}

function onCreate()
{
    final content = Paths.getContent('script.hx');
    
    var script:Script = new Script(FlxG.state);

    debugTrace(script.execute(content));
}

/*
var ops = [
    'a' => {
        func: (arg) -> (arg + 1) / 2,
        args: [-1, 1, 3, 5]
    },
    'b' => {
        func: (arg) -> 2 * Math.pow(arg, 2) - 2,
        args: [-2, -1, 0, 1, 2]
    },
    'c' => {
        func: (arg) -> Math.pow(arg, 3) - 3 * arg,
        args: [-2, -1, 0, 1, 2]
    },
    'd' => {
        func: (arg) -> Math.sqrt(arg + 2),
        args: [-3, -2, 2, 7]
    }
];

for (key in ops.keys())
    for (arg in ops[key].args)
        debugTrace(key + '. ' + arg + ': ' + ops[key].func(arg));
*/