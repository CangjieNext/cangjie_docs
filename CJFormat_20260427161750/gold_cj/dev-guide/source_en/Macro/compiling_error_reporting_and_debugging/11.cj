public macro M(input: Tokens) {
    let a = @M2(1+2) // M2 is inside macro M, not suitable for debug mode.
    return input + quote($a)
}