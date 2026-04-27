interface I {
    func f(): Unit
}

open class C <: I {
    protected func f() {} // Compiler Error, f needs to be public semantics
}