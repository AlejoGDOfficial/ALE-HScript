package ale.hscript;

import haxe.Exception;

import ale.hscript.Types.Expr;
import ale.hscript.Types.Stmt;

class Script
{
    public var interp:Interp;
    public var lexerClass:Class<Lexer>;
    public var parserClass:Class<Parser>;

    public function new(?interp:Interp, ?lexerClass:Class<Lexer>, ?parserClass:Class<Parser>)
    {
        this.interp = interp ?? new Interp();
        this.lexerClass = lexerClass ?? Lexer;
        this.parserClass = parserClass ?? Parser;
    }

    public function execute(content:String):Dynamic
    {
        final lexer:Lexer = Type.createInstance(lexerClass, []);
        lexer.content = content;

        final parser:Parser = Type.createInstance(parserClass, []);
        parser.tokens = lexer.tokenize();

        final statements:Stmt = parser.parse();

        return interp.execute(statements);
    }

    public function safeExecution(content:String):Dynamic
    {
        try
        {
            return execute(content);
        } catch(e:Exception) {
            trace('Script Exception: ' + e);
        }

        return null;
    }
}