func add(i: Int64, j: Int64) {
    i + j
}

func add(i: Float64, j: Float64) {
    i + j
}

main() {
    var f = add   // Error, ambiguous function 'add'
    var plus: (Int64, Int64) -> Int64 = add  // OK
}