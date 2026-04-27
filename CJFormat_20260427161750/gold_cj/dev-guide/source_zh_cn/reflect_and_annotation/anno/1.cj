@OverflowThrowing
func add(a: Int8, b: Int8) {
    return a + b
}

main() {
    add(100, 29)
    /* 100 + 29 在数学上等于 129，
     * 在 Int8 的表示范围上发生了上溢出，
     * 程序抛出异常
     */
}
