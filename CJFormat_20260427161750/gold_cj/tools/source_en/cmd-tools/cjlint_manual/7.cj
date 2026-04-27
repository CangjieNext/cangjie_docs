func foo(a: Int64, b: Int64, c: Int64, d: Int64) { /*cjlint-ignore !G.FUN.02description*/
    return a + b + c // ERROR: Missing space before description
}
