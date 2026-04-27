enum TimeUnit {
    | Year(UInt64)
    | Month(UInt64)
}

main() {
    let x = Year(2)
    let s = match (x) {
        case Year(5) => "1:OK"
        case Month(m) => "2:OK"
        case Year(0) | Year(1) | Month(_) => "3:OK"
        case Year(_) => "4:OK"
        case Year(2) | Month(m) => "5:invalid" // Error, Variable cannot be introduced in patterns connected by '|'
        case Year(n: UInt64) | Month(n: UInt64) => "6:invalid" // Error, Variable cannot be introduced in patterns connected by '|'
    }
    println(s)
}
