package ale.hscript;

class Types {}

enum Token
{
    TIdent(id:String);

    TEqual;

    TString(id:String);
    TNumber(value:Float);

    TLParen;
    TRParen;
    TOp(op:String);

    TLBrace;
    TRBrace;
    
    TDot;
    TSemiColon;
    TColon;
    TQuestion;
    
    TVar;
    TFinal;
    TClass;
    TEnum;
    TTypedef;
    TAbstract;
    TFunction;
    TPackage;
    TImport;
    TAs;

    TNull;
    TTrue;
    TFalse;
}

enum Expr
{
    ENull;
    ETrue;
    EFalse;

    ENumber(num:Float);
    EString(value:String);

    EVar(name:String);
    EProperty(object:Expr, property:String);

    EBinOp(left:Expr, op:String, rigth:Expr);
    EUnOp(op:String, rigth:Expr);

    ECall(obj:Expr, args:Array<Expr>);
}

typedef FunctionArgument = {
    name:String,
    ?value:Bool
};

enum Stmt
{
    SVar(name:String, val:Expr);

    SReturn(value:Expr);

    SIf(bool:Expr, block:Stmt, ?elseIf:Stmt);

    SFunction(id:String, args:Array<FunctionArgument>, block:Stmt);

    SBlock(statements:Array<Stmt>);
}