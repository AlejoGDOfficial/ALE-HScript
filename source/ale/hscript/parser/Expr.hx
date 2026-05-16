package ale.hscript.parser;

import ale.hscript.lexer.Token;

enum Expr
{
    EProgram(exprs:Array<Expr>);

    ENumber(val:Float);
    EString(val:String);
    EType(module:Array<String>);

    ETrue;
    EFalse;
    ENull;

    EVarRef(name:String);
    EField(obj:Expr, name:String);

    EBlock(exprs:Array<Expr>);

    ESet(obj:Expr, name:String, value:Expr);

    EBinOp(left:Expr, op:Token, right:Expr);
    EPrefix(op:Token, right:Expr);

    ECall(obj:Expr, args:Array<Expr>);

    EImport(path:Array<String>, wildcard:Bool, ?nick:String);
    EPackage(path:Array<String>);

    EReturn(value:Expr);
}