package;

class Parser extends scripting.haxe.ScriptBasic
{
    final tokens:Token;
    
    public function new(tokens:Array<Token>)
    {
        super();
        
        this.tokens = tokens;
    }
    
    public function parse():Array<Stmt>
    {
        final result:Array<Stmt> = [];
        
        return result;
    }
}