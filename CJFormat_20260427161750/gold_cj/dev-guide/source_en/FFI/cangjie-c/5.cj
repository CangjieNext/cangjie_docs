main() {
    var ptr = CPointer<Int8>()
    var f = CFunc<() -> Unit>(ptr)
    unsafe { f() } // core dumped when running, because the pointer is nullptr.
}
