interface Sizeable {
    prop size: Int64
}

extend<T> Array<T> <: Sizeable {}

main() {
    let a: Sizeable = Array<Int64>()
    println(a.size)
}