package ale.hscript.parser;

import ale.hscript.lexer.Token;

enum Expr
{
    ENull;
    ETrue;
    EFalse;

    ENumber(value:Float);
    EString(value:String);

    EImport(cls:Expr, ?nick:String);

    EIdent(id:Array<String>);

    EInstance(cls:Expr, args:Array<Expr>);
    
    ECall(obj:Expr, args:Array<Expr>);

    EAssign(left:Expr, value:Expr);

    EBinOp(left:Expr, op:Token, right:Expr);
    EPrefix(op:Token, right:Expr);
    EPostfix(left:Expr, op:Expr);

    EIf(condition:Expr, thenExpr:Expr, ?elseExpr:Expr);
    EWhile(condition:Expr, thenExpr:Expr);
    EDoWhile(condition:Expr, thenExpr:Expr);
    
    EVar(name:String, ?value:Expr);
    EFunction(name:String, args:Array<FunctionArgument>, block:Expr);

    EBlock(stmts:Array<Expr>);

    EProgram(stmts:Array<Expr>);

    EReturn(value:Expr);
}