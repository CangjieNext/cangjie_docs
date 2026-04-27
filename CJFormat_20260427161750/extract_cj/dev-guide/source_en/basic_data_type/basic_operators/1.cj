main(): Int64 {
    var a = 1
    var b = 1
    a = (b = 0) // Compilation error: the type of the assignment expression is Unit, and its value is ()
    if (a = 5) { // Compilation error: the type of the assignment expression is Unit, and its value is ()
    }
    a = b = 0 // Syntax error: chained use of assignments is not supported

    return 0
}