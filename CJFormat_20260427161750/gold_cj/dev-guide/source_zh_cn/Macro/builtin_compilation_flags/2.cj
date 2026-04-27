@FastNative
foreign func foo(): CPointer<Int32>

@FastNative
foreign func printf(fmt: CPointer<Int32>, ...): Int32

main(): Int32 {
    unsafe {
        let str = foo()
        printf(str)
    }
}
