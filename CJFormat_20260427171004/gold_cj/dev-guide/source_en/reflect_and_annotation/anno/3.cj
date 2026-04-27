@OverflowWrapping
main() {
    let res: Int8 = Int8(105) * Int8(4)
    /* Mathematically, 105 * 4 equals 420,
     * whose binary representation is 1 1010 0100,
     * exceeding the 8-bit memory space for the result.
     * The truncated result is represented as 1010 0100 in binary,
     * corresponding to the signed integer -92
     */
    let temp: Int16 = Int16(-132)
    let con: UInt8 = UInt8(temp)
    /* -132's binary representation is 1111 1111 0111 1100,
     * exceeding the 8-bit memory space for the result.
     * The truncated result is represented as 0111 1100 in binary,
     * corresponding to the signed integer 124
     */
}
