package;

CoolUtil.resizeGame(500, 500, false);

MobileAPI.setOrientation('portrait');

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
    
    var script:Script = new Script();

    debugTrace(script.execute(content));
}