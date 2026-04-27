func foo(a: Int64, b: Int64, c: Int64, d: Int64) { /*cjlint-ignore !G.FUN.02!G.FUN.01*/
    return a + b + c // ERROR: Missing space between rules
}
