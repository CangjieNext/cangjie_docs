func f<T>(x: T) where T <: ToString {
    println("item: ${x}")
}

func f(arr: Array<Int64>) {
    println("array: ${arr}")
}

main() {
    f()
    f(1)
    f(1, 2)
}