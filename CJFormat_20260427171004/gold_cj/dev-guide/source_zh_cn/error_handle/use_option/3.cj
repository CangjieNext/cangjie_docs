main() {
    let a = Some(1)
    let b: ?Int64 = None
    let r1: Int64 = a ?? 0
    let r2: Int64 = b ?? 0
    println(r1)
    println(r2)
}
