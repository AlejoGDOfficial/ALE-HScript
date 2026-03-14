package;

enum Expr
{
    ENull;

    ENumber(num:Float);
    EString(value:String);

    EVar(name:String);
    EProperty(variable:Expr, property:String);
    EAssign(name:String, value:Expr);

    EBinOp(left:Expr, op:String, right:Expr);
}