package;

import Token;

class Tokenizer extends scripting.haxe.ScriptBasic
{
    final identReg:EReg = ~/^[A-Za-z_][A-Za-z0-9_]*$/;
    final spaceReg = ~/\s+/;
    
    public function tokenize(content:String):Array<Token>
    {
        final result:Array<Token> = [];
        
        var index:Int = 0;
        
        while (index < content.length)
        {
            var cur:String = content.charAt(index);
            
            switch (cur)
            {
                case ':':
                    index++;
                    
                    result.push(Token.TColon);
                
                    continue;
                case ';':
                    index++;
                    
                    result.push(Token.TSemiColon);
                    
                    continue;
                default:
            }
            
            if (spaceReg.match(cur))
            {
                index++;
                
                continue;
            } else if (identReg.match(cur)) {
                final string:String = cur;
                
                while (index < content.length && identReg.match(content.charAt(++index)))
                    string += content.charAt(index);
                
                result.push(Token.TIdent(string));
                
                continue;
            } else if (cur == '\'') {
                final string:String = '';
                
                while (index < content.length && content.charAt(++index) != '\'')
                    string += content.charAt(index);
                
                index++;
            
                result.push(Token.TString(string));
                
                continue;
            }
            
            index++;
        }
        
        return result;
    }
}