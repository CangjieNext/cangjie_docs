import std.ast.*

let intList: Array<Int64> = [1, 2, 3, 4, 5]
let float: Float64 = 1.0
let str: String = "Hello"
let tokens = quote(
    arr = $(intList)
    x = $(float)
    s = $(str)
)

main() {
    println(tokens)
}
