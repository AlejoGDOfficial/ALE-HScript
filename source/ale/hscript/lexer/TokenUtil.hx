package ale.hscript.lexer;

class TokenUtil
{
    public static final symbolFromString:Map<String, Token> = [
        '*' => TStar,
        '/' => TSlash,
        '%' => TPercent,

        '>' => TGreater,
        '<' => TLess,

        '&' => TAmpersand,
        '|' => TPipe,

        '^' => TCaret,
        '~' => TTilde,

        '(' => TLeftParen,
        ')' => TRightParen,

        '{' => TLeftBrace,
        '}' => TRightBrace,

        '[' => TLeftBracket,
        ']' => TRightBracket,

        '.' => TDot,
        ',' => TComma,
        ':' => TColon,
        ';' => TSemicolon,
        '?' => TQuestion,

        '@' => TAt,
        '$' => TDollar
    ];

    public static final keywordFromString:Map<String, Token> = [
        'null' => TNull,
        'true' => TTrue,
        'false' => TFalse,

        'if' => TIf,
        'else' => TElse,
        'for' => TFor,
        'while' => TWhile,
        'do' => TDo,

        'continue' => TContinue,
        'break' => TBreak,
        'return' => TReturn,

        'new' => TNew,

        'var' => TVar,
        'final' => TFinal,
        'function' => TFunction,

        'class' => TClass,
        'enum' => TEnum,
        'typedef' => TTypedef,
        'abstract' => TAbstract,
        'interface' => TInterface,

        'to' => TTo,
        'from' => TFrom,

        'package' => TPackage,
        'import' => TImport,
        'as' => TAs
    ];
}