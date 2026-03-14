package;

class Script extends scripting.haxe.ScriptBasic
{
    public var interp:Interp;
    
    public function new()
    {
        super();
        
        //this.interp = new Interp();
    }
    
    public function execute(content:String)
    {
        final tokens:Array<Token> = new Tokenizer(content).tokenize();
    
        final ast:Array<Stmt> = new Parser(tokens).parse();
        
        debugTrace(ast);
    }
}