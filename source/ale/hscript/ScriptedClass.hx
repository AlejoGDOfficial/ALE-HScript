package ale.hscript;

import ale.hscript.lexer.Lexer;

import ale.hscript.parser.ClassParser;
import ale.hscript.parser.Expr;

import ale.hscript.classes.ScriptedInstance;

using StringTools;

class ScriptedClass
{
    public final path:String;

    public final name:String;

    public final content:String;

    public final program:Expr;

    public function new(path:String)
    {
        this.path = path;

        name = Config.MODULE_PATH + path.replace('.', '/') + Config.MODULE_EXTENSION;

        content = Config.FILE_READER(name);

        program = new ClassParser(new Lexer(content).tokenize()).parse();
    }

    public function instantiate(?args:Array<Dynamic>):ScriptedInstance
        return new ScriptedInstance(this, args);
}