enum RGBColor {
    | Red | Green | Blue
}

main() {
    let x = Red
    let y = match (x) {
        case Red => "red" // The 'Red' is enum mode here.
        case _ => "not red"
    }
    println(y)
}