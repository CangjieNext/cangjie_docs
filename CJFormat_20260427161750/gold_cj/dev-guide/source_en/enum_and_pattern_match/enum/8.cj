class Blue {}

enum RGBColor {
    | Red | Green(UInt8) | Blue(UInt8)
}

let r = Red // OK: constructed by enum type name

let g = Green(100) // OK: constructed by enum type name

let b = Blue(100) // Will choose constructor of 'class Blue' and report an error
