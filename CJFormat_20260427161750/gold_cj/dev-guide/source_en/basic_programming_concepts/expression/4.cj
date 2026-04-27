var a = 10
var b: Int64 = if (a == 10) { // Error, mismatched types
    "this is 10"
} else {
    "this is not 10"
}
