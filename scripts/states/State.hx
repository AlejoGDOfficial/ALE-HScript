package;

CoolUtil.resizeGame(500, 500);

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
    script.execute(content);
}