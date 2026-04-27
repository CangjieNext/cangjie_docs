open class U1 {}

class U2 <: U1 {}

open class S1 {}

class S2 <: S1 {}

func f(a: U1): S2 {
    S2()
}

func g(a: U2): S1 {
    S1()
}

func call1() {
    g(U2()) // OK
    f(U2()) // OK
}

func h(lam: (U2) -> S1): S1 {
    lam(U2())
}

func call2() {
    h(g) // OK
    h(f) // OK
}
