package ale.hscript.parser;

import ale.hscript.lexer.Token;

enum Expr
{
    EProgram(exprs:Array<Expr>);

    ENumber(val:Float);
    EString(val:String);

    EType(module:String);

    ETrue;
    EFalse;
    ENull;

    EVar(name:String, value:Expr);

    EField(obj:Expr, name:String);

    ENew(type:Expr, args:Array<Expr>);

    EFunction(name:String, args:Array<FunctionArgument>, block:Expr);

    EBlock(exprs:Array<Expr>);

    ESet(obj:Expr, value:Expr, ?returnNew:Bool);

    EBinOp(left:Expr, op:Token, right:Expr);
    EPrefix(op:Token, right:Expr);
    EPostfix(left:Expr, op:Token);

    ECall(obj:Expr, args:Array<Expr>);

    EImport(path:String, wildcard:Bool, ?nick:String);
    EPackage(pack:String);

    EReturn(value:Expr);
}