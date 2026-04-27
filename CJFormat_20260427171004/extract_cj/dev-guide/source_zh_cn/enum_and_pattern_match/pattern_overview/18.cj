enum RGBColor {
    | Red | Green | Blue
}

main() {
    let c = Blue
    let cs = match (c) {
        case Red => "Red"
        case Green => "Green"
        case _ => "Other" // Matched.
    }
    println(cs)
}