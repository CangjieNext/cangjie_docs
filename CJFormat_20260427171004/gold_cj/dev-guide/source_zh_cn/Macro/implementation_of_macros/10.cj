// file macro_definition.cj
macro package macro_definition

import std.ast.*

public macro ModifyFunc(input: Tokens): Tokens {
    println("I'm in macro body")
    let funcDecl = FuncDecl(input)
    return quote(
        func $(funcDecl.identifier)(id: Int64) {
            println("start ${id}")
            $(funcDecl.block.nodes)
            println("end")
        })
}
