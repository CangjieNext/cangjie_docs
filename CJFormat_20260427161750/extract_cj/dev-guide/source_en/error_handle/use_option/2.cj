func getString(p: ?Int64): String{
    match (p) {
        case Some(x) => "${x}"
        case None => "none"
    }
}
main() {
    let a = Some(1)
    let b: ?Int64 = None
    let r1 = getString(a)
    let r2 = getString(b)
    println(r1)
    println(r2)
}