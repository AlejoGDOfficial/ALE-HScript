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
    TCommma;
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

    TIf;
    TElse;

    TNull;
    TTrue;
    TFalse;

    TArrow;
}

enum Expr
{
    ENull;
    ETrue;
    EFalse;

    ENumber(num:Float);
    EString(value:String);

    EProperty(object:Null<Expr>, property:String);

    EBinOp(left:Expr, op:String, rigth:Expr);
    EUnOp(op:String, rigth:Expr);
}

typedef FunctionArgument = {
    name:String,
    ?value:Expr
};

enum Stmt
{
    SVar(name:String, val:Expr);

    SReturn(value:Expr);

    SIf(condition:Expr, block:Stmt, ?elseIf:Stmt);

    SFunction(id:String, args:Array<FunctionArgument>, block:Stmt);

    SBlock(statements:Array<Stmt>);

    SAssign(obj:Expr, val:Expr);
    
    SCall(obj:Expr, args:Array<Expr>);
}