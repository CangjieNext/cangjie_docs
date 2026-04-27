let Red = 1

func Green(g: UInt8) {
    return g
}

enum RGBColor {
    | Red | Green(UInt8) | Blue(UInt8)
}

let r1 = Red                 // Will choose 'let Red'
let r2 = RGBColor.Red        // OK: constructed by enum type name

let g1 = Green(100)          // Will choose 'func Green'
let g2 = RGBColor.Green(100) // OK: constructed by enum type name

let b = Blue(100)            // OK: can be uniquely identified as an enum constructor