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
    EVarRef(name:String);
    EField(obj:Expr, name:String);

    ENew(type:Expr, args:Array<Expr>);

    EFunction(name:String, args:Array<FunctionArgument>, block:Expr);

    EBlock(exprs:Array<Expr>);

    ESet(name:String, value:Expr);
    ESetField(obj:Expr, name:String, value:Expr);

    EBinOp(left:Expr, op:Token, right:Expr);
    EPrefix(op:Token, right:Expr);

    ECall(obj:Expr, args:Array<Expr>);

    EImport(path:Array<String>, wildcard:Bool, ?nick:String);
    EPackage(path:Array<String>);

    EReturn(value:Expr);
}