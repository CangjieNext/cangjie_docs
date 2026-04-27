main() {
    let a = Some(1)
    let b: ?Int64 = None
    let r1 = a.getOrThrow()
    println(r1)
    try {
        let r2 = b.getOrThrow()
    } catch (e: NoneValueException) {
        println("b is None")
    }
}