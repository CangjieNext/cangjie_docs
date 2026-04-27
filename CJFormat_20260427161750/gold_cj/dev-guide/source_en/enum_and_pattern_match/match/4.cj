enum RGBColor {
    | Red(Int16) | Green(Int16) | Blue(Int16)
}

main() {
    let c = RGBColor.Green(-100)
    let cs = match (c) {
        case Red(r) where r < 0 => "Red = 0"
        case Red(r) => "Red = ${r}"
        case Green(g) where g < 0 => "Green = 0" // Matched.
        case Green(g) => "Green = ${g}"
        case Blue(b) where b < 0 => "Blue = 0"
        case Blue(b) => "Blue = ${b}"
    }
    print(cs)
}
