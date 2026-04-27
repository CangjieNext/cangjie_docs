@CallingConv[CDECL]   // Can be omitted in default.
foreign func rand(): Int32

main() {
    println(unsafe { rand() })
}