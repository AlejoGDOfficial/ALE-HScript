package;

enum Expr
{
    ENumber(num:Float);
    EString(value:String);

    EVar(name:String);
    EAssign(name:String, value:Expr);

    EBinary(left:Expr, op:String, right:Expr);
}