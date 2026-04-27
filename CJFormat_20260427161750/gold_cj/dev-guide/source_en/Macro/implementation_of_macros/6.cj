package macro_calling

import macro_definition.*

main(): Int64 {
    println("I'm in function body")
    let a: Int64 = @testDef(1 + 2)
    println("a = ${a}")
    return 0
}
