package ale.hscript;

import ale.hscript.lexer.Lexer;
import ale.hscript.parser.Parser;

import haxe.Exception;

class Script
{
    public final name:String;

    public final content:String;

    public function new(?script:String)
    {
        final path:String = Config.SCRIPT_PATH + script + Config.SCRIPT_EXTENSION;

        final isFile:Bool = Config.FILE_CHECKER(path);

        content = isFile ? Config.FILE_READER(path) : script;

        name = isFile ? path : Config.INTERP_NAME;
    }

    public function execute():Dynamic
    {
        final tokens = new Lexer(content).tokenize();

        trace(tokens);

        final expr = new Parser(tokens).parse();

        trace(expr);

        return null;
    }

    public function safeExecute():Dynamic
    {
        try
        {
            return execute();
        } catch(error:Exception) {
            Config.ERROR_HANDLER(name + ': ' + error.message);
        }

        return null;
    }
}