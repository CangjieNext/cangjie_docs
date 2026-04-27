@OverflowThrowing
main() {
    let res: Int8 = Int8(100) + Int8(29) // Error, arithmetic operation '+' overflow

    // Mathematically, 100 + 29 equals 129, causing an upper overflow in Int8's range; the compiler detects and reports this
    let con: UInt8 = UInt8(-132) // Error, integer type conversion overflow
    /* -132 causes a lower overflow in UInt8's range,
     * resulting in an exception being thrown
     */
}
