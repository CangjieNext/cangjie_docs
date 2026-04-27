func test1() {
    let s: String = @sourceFile()  // The value of `s` is the current source file name
}

func test2(n!: Int64 = @sourceLine()) { /* at line 5 */
    // The default value of `n` is the source file line number of the definition of `test2`
    println(n) // print 5
}