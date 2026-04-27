func genericPrint<T>(a: T) where T <: ToString {
    println(a)
}

main() {
    genericPrint<Int64>(10)
}