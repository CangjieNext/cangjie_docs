extend Int64 {
    public operator func +(x: Int64, y: Int64): Int64 { // Error, invalid number of parameters for operator '+'
        x + y
    }
}
