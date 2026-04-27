@OverflowSaturating
main() {
    let res: Int8 = Int8(-100) - Int8(45)
    /* Mathematically, -100 - 45 equals -145,
     * which causes a lower overflow in Int8's range,
     * so Int8's minimum value -128 is chosen as the result
     */
    let con: Int8 = Int8(1024)
    /* 1024 causes an upper overflow in Int8's range,
     * so Int8's maximum value 127 is chosen as the result
     */
}
