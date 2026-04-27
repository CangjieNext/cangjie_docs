func power(n: Int64, e: Int64) {
    var result = 1
    var vn = n
    var ve = e
    while (ve > 0) {
        if (ve % 2 == 1) {
            result *= vn
        }
        ve /= 2
        if (ve > 0) {
            vn *= vn
        }
    }
    result
}