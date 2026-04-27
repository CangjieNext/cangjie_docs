main() {
    let x = -10
    let y = match (x) {
        case 0 => "zero"
        case n => "x is not zero and x = ${n}" // Matched.
    }
    println(y)
}