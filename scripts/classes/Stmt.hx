package;

enum Stmt
{
    SVar(name:String, value:Expr);
    SAssign(obj:Expr, value:Expr);

    SReturn(value:Expr);

    SIf(bool:Expr, block:Stmt, ?elseBlock:Stmt);

    SBlock(statements:Array<Stmt>);
}