package;

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
    
    TSemiColon;
    TColon;
}