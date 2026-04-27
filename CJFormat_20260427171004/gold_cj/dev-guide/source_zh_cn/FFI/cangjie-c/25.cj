@C
func myCallback(s: Int32): Unit {
    println("handle ${s} in callback")
}

main() {
    // the argument is a function qualified by `@C`
    unsafe { set_callback(myCallback) }

    // the argument is a lambda with `CFunc` type
    let f: CFunc<(Int32) -> Unit> = {i => println("handle ${i} in callback")}
    unsafe { set_callback(f) }
}
