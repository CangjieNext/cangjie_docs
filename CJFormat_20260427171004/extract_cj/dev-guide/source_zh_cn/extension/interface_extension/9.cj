interface I<N> {
    func foo(n: N): N {n}
}

open class B<T> {}

extend<T> B<T> <: I<T> {}

class A <: B<Int64>{}

main() {
    A().foo(0) // this call triggers unexpected behaviour
}