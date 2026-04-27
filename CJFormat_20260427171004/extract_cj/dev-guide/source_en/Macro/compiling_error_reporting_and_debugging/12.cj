// main.cj

main() {
    // For macros with parentheses, newlines introduced by debug mode will change the semantics
    // of the expression, so it is not suitable for debug mode.
    let t = @M(1+2)
}