package ale.hscript;

import ale.hscript.Types.Token;
import ale.hscript.Types.Expr;
import ale.hscript.Types.Stmt;

import haxe.Constraints.IMap;

class Parser
{
    public var tokens:Array<Token> = [];

    public function new() {}

    var pos:Int = 0;

    function peek():Token
        return tokens[pos];

    function peekLast():Token
        return tokens[pos - 1];

    function peekNext():Token
        return tokens[pos + 1];

    function advance():Token
        return tokens[pos++];

    function isEnd():Bool
        return pos >= tokens.length;

    final parseMap:Map<Token, Dynamic> = [
        // Variable
        TIdent('var') => cast [
            TIdent(null) => cast [
                TColon => cast [
                    TIdent(null) => cast [
                        TEqual => '',
                        TSemiColon => ''
                    ],
                ],
                TEqual => '',
                TSemiColon => ''
            ]
        ],

        // Function
        TIdent('function') => cast [
            TIdent(null) => cast [
                TLParen => cast [
                    TRParen => cast [
                        TLBrace => cast [
                            TRBrace => ''
                        ]
                    ]
                ]
            ]
        ],

        // Class
        TIdent('class') => cast [
            TIdent(null) => cast [
                TLBrace => cast [
                    TRBrace => ''
                ]
            ]
        ]
    ];

    public function parse():Array<Stmt>
    {
        final result:Array<Stmt> = [];

        while (!isEnd())
        {
            final res = revursiveParseMap(parseMap);

            trace(res);
        }

        return [];
    }

    public function revursiveParseMap(map:IMap<Token, Dynamic>):Dynamic
    {
        final curToken:Token = peek();

        final nullToken:Token = nullEnum(peek());
        
        if (map.exists(curToken) || map.exists(nullToken))
        {
            final mapRes:Dynamic = map.get(advance()) ?? map.get(nullToken);

            if (mapRes is IMap)
                return revursiveParseMap(mapRes);
            else
                return mapRes;
        } else {
            advance();
        }

        return 'ERROR';
    }

    function nullEnum<T>(value:T):T
    {
        var enumValue:EnumValue = cast value;
        var params = Type.enumParameters(enumValue);
        
        if (params.length == 0)
            return value;

        return cast Type.createEnum(Type.getEnum(enumValue), Type.enumConstructor(enumValue), [for (_ in params) null]);
    }
}