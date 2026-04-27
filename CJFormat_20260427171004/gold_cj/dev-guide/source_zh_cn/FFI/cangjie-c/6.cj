foreign func foo1(ptr: CPointer<Int32>): Unit

@C
func foo2(ptr: CPointer<Int32>): Unit {
    let n = unsafe { ptr.read() }
    println("*ptr = ${n}")
}

let foo3: CFunc<(CPointer<Int32>) -> Unit> = {
    ptr =>
        let n = unsafe { ptr.read() }
        println("*ptr = ${n}")
}

struct Data {
    var n: Int32 = 0
}

class A {
    var data = Data()
}

main() {
    var n: Int32 = 0
    unsafe {
        foo1(inout n) // OK
        foo2(inout n) // OK
        foo3(inout n) // OK
    }
    var data = Data()
    var a = A()
    unsafe {
        foo1(inout data.n) // OK
        foo1(inout a.data.n) // Error, n is derived indirectly from instance member variables of class A
    }
}
