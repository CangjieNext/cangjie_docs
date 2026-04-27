main() {
    let x = -10
    let y = match (x) {
        case 0 => "zero"
        case n =>
            let n = 0 // Error, redefinition
            println(n)
            "x is not zero"
    }
    println(y)
}
