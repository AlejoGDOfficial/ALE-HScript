package;

enum Expr
{
    ENull;

    ENumber(num:Float);
    EString(value:String);

    EVar(name:String);
    EProperty(object:Expr, property:String);

    EBinOp(left:Expr, op:String, right:Expr);
}