## Tokenizer

Nothing complicated.

## Parser

* Statement
    * Ident
        * Variable
            * var -> {:type} -> {Expr} -> `;`
        * Return
            * return -> Expr -> `;`
        * Default
            * Assign
                * Ident -> AssignOp -> value -> `;`
    * Block
        * `{` -> Statement -> `}`
* Expression
    * AddSub
        * MulDiv -> `+ | -` -> MulDiv
    * MulDiv
        * Primary -> `* | /` -> Primary
    * Primary
        * String
        * Number
        * Ident
            * Var
        * LParen
            * Expr -> `)`

## Interp

* Statement
    * Var
        1. Define Variable
        1. Evaluate
    * Assign
        1. Assign Variable
        1. Evaluate
    * Return
        1. Evaluate
    * Block
        1. Save Previous Scope
        1. Set New Scope
        1. FOR Statements -> Statement
        1. Reset Scope
* Evaluate
    * String
    * Variable
    * Number
    * BinOp
        * `+`
        * `-`
        * `*`
        * `/`
        * `%`
        * `==`
        * `!=`
        * `>`
        * `<`
        * `>=`
        * `<=`
        * `&&`
        * `||`
        * `&`
        * `|`
        * `^`
        * `<<`
        * `>>`
        * `>>>`