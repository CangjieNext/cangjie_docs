foreign func rand(): Int32 { // compiler error
    return 0
}
@C
foreign var a: Int32 = 0 // compiler error
@C
foreign class A{} // compiler error
@C
foreign interface B{} // compiler error