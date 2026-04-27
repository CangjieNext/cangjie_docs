@OverflowThrowing
main() {
    let res: Int8 = Int8(100) + Int8(29) // Error, arithmetic operation '+' overflow

    // 100 + 29 在数学上等于 129，在 Int8 的表示范围上发生了上溢出，编译器检测出来并报错
    let con: UInt8 = UInt8(-132) // Error, integer type conversion overflow
    /* -132 在 UInt8 的表示范围上发生了下溢出，
     * 程序抛出异常
     */
}
