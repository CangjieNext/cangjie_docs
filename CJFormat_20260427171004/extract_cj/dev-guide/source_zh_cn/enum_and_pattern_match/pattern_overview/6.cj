main() {
    let x = -10
    let y = match (x) {
        case 0 => "zero"
        case n => n = n + 0 // Error, 'n' cannot be modified.
                  "x is not zero"
    }
    println(y)
}