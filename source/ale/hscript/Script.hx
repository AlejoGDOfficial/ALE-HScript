package ale.hscript;

import ale.hscript.lexer.Lexer;
import ale.hscript.parser.Parser;
import ale.hscript.interp.Interp;

import haxe.Timer;

import haxe.Exception;

class Script
{
    public final content:String;

    public final interp:Interp;

    public function new(?script:String, ?name:String)
    {
        final path:String = Config.SCRIPT_PATH + script + Config.SCRIPT_EXTENSION;

        final isFile:Bool = Config.FILE_CHECKER != null && Config.FILE_CHECKER(path);

        content = isFile ? Config.FILE_READER(path) : script;

        interp = new Interp(name ?? (isFile ? path : Config.INTERP_NAME));
    }

    public function execute():Dynamic
    {
        final startTime:Float = Timer.stamp();

        final tokens = new Lexer(content).tokenize();

        final expr = new Parser(tokens).parse();

        final result = interp.execute(expr);

        final endTime:Float = Timer.stamp();

        trace('Time: ' + (endTime - startTime));

        return result;
    }

    public function safeExecute():Dynamic
    {
        try
        {
            return execute();
        } catch(error:Exception) {
            Config.ERROR_HANDLER(interp.name + ': ' + error.message);
        }

        return null;
    }
}