func power_10(n: Int64) {
    var vn = n
    vn *= vn // vn = n ^ 2
    var result = vn // result = n ^ 2
    vn *= vn // vn = n ^ 4
    vn *= vn // vn = n ^ 8
    result *= vn // result = n ^ 10
    result
}
