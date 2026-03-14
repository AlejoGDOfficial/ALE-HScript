package;

enum Expr
{
    EString(value:String);
    EVar(name:String);
    ENumber(num:Float);
    EBinary(left:Float, op:String, right:Float);
}