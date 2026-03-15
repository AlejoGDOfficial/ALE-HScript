package;

class Script
{
    public var superInstance(default, set):Dynamic;
    function set_superInstance(value:Dynamic)
    {
        superInstance = value;

        interp.superInstance = value;

        return superInstance;
    }

    public var interp:Interp;
    
    public function new(?superInstance:Dynamic)
    {
        this.interp = new Interp();

        this.superInstance = superInstance;
    }
    
    public function execute(content:String):Dynamic
    {
        final tokens:Array<Token> = new Tokenizer(content).tokenize();
    
        final ast:Array<Stmt> = new Parser(tokens).parse();
        
        return interp.execute(ast);
    }
}