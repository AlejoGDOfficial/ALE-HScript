package;

enum Token
{
    TIdent(id:String);
    TString(id:String);
    TNumber(value:Float);
    TOp(op:String);
    TLParen;
    TRParen;
    TSemiColon;
    TEqual;
    TColon;
}