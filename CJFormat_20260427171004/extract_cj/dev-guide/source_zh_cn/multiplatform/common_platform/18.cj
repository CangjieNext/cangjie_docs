// common file
package cmp

public common interface I {
}

public open common class A <: I {
    public init() {}
    public open func foo5(): Unit { println("A::foo5 common") }
}

public common class A2 <: A {
    public init() {}
}

public common class B <: I {
    public init() {}
}

public func runCommonA(a: A) {
    a.foo5()
}

public func runCommonA2(a: A2) {
    a.foo5()
}