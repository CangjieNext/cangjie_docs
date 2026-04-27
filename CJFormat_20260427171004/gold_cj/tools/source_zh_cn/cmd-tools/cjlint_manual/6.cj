func foo(a: Int64, b: Int64, c: Int64, d: Int64) { /*cjlint-ignore !G.FUN.02!G.FUN.01*/
    return a + b + c // ERROR: 规则间没用空格隔开，屏蔽告警失败
}
