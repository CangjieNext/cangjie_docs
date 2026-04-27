foreign func rand(): Int32

main() {
    var ptr = CPointer<Int8>(rand)
}
