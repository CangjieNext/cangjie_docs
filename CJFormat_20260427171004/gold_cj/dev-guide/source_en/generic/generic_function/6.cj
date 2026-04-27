extend Int64 {
    func printIntAndArg<T>(a: T) where T <: ToString {
        println(this)
        println("${a}")
    }
}

main() {
    var a: Int64 = 12
    a.printIntAndArg<String>("twelve")
}
