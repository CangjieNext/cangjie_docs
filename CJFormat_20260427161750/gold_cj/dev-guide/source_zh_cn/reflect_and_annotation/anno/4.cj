@OverflowSaturating
main() {
    let res: Int8 = Int8(-100) - Int8(45)
    /* -100 - 45 在数学上等于 -145，
     * 在 Int8 的表示范围上发生了下溢出，
     * 选择 Int8 的最小值 -128 作为结果
     */
    let con: Int8 = Int8(1024)
    /* 1024 在 Int8 的表示范围上发生了上溢出，
     * 选择 Int8 的最大值 127 作为结果
     */
}
