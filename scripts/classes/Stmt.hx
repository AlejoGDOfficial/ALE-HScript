package;

enum Stmt
{
    SVar(name:String, value:Expr);
    SAssign(object:Expr, value:Expr);

    SReturn(value:Expr);

    SBlock(statements:Array<Stmt>);
}