@OverflowThrowing
func add(a: Int8, b: Int8){
    return a + b
}
main() {
    add(100,29)
    /* Mathematically, 100 + 29 equals 129,
    * which causes an upper overflow in Int8's range,
    * resulting in an exception being thrown
    */
}