// common file
package cmp

common enum A {
    ELEMENT1 | ELEMENT2
}

common enum B {
    ELEMENT1 | ELEMENT2
}

common enum C {
    ELEMENT1 | ELEMENT2
}

common enum D {
    ELEMENT1 | ELEMENT2 | ...
}

common enum E {
    ELEMENT1 | ELEMENT2 | ...
}

common enum Either<L, R> where L <: Equatable<L>, R <: Equatable<R> {
    | Left(L)
    | Right(R)

    common func goo(x: L): Unit
    common func foo<M>(x: M): Unit
}
