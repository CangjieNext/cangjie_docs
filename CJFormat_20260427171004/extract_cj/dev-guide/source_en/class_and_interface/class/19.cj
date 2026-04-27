open class C1 {
    func f(): This {  // its type is `() -> C1`
        return this
    }

    func f2() { // its type is `() -> C1`
        return this
    }

    public open func f3(): C1 {
        return this
    }
}
class C2 <: C1 {
    // member function f is inherited from C1, and its type is `() -> C2` now
    public override func f3(): This { // OK
        return this
    }
}

main() {
    var obj1: C2 = C2()
    var obj2: C1 = C2()

    var x = obj1.f()    // During compilation, the type of x is C2
    var y = obj2.f()    // During compilation, the type of y is C1
}