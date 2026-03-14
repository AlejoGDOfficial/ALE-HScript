package;

enum Stmt
{
    SVar(name:String, value:Expr);
    SReturn(value:Expr);
}