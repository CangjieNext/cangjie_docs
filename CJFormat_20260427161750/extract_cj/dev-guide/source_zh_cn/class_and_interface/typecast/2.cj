main() {
    let x: Rune = 'a'
    let y: UInt32 = 65
    let r1 = UInt32(x)
    let r2 = Rune(y)
    println("The type of r1 is 'UInt32', and r1 = ${r1}")
    println("The type of r2 is 'Rune', and r2 = ${r2}")
}