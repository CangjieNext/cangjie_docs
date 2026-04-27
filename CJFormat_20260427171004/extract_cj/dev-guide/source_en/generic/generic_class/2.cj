class A<T> {}
class B<T> {
    static func foo() {1}
    static var err1: A<T> = A<T>() // Error, static member cannot depend on generic parameter 'Generics-T'
    static prop err2: A<T> { // Error, static member cannot depend on generic parameter 'Generics-T'
        get() {
            A<T>() // Error, static member cannot depend on generic parameter 'Generics-T'
        }
    }
    static var vfoo = foo() // Error, it's equal to 'static var vfoo = B<T>.foo()', implicit reference to generic 'T'.
    static var ok: Int64 = 1
}

main() {
    B<Int32>.ok = 2
    println(B<Int64>.ok) // 2
}