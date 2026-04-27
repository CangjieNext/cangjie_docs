// macro_definition.cj
macro package macro_definition

import std.ast.*

public macro testDef(input: Tokens): Tokens {
    for (i in 0..input.size) {
        if (input[i].kind == IDENTIFIER) {
            diagReport(DiagReportLevel.ERROR, input[i..(i + 1)], "This expression is not allowed to contain identifier",
                "Here is the illegal identifier")
        }
    }
    return input
}
