package;

enum Stmt
{
    SVar(name:String, value:Expr);
    SAssign(name:String, value:Expr);

    SReturn(value:Expr);

    SBlock(statements:Array<Stmt>);
}