package;

enum Stmt
{
    SVar(name:String, value:Expr);
    SAssign(name:String, value:Expr);

    SReturn(value:Expr);

    SIf(bool:Expr, block:Stmt, ?elseBlock:Stmt);

    SBlock(statements:Array<Stmt>);
}