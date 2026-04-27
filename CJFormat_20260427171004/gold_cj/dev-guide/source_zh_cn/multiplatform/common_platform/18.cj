// common file
package cmp

common public interface I {}

common public open class A <: I {
    public init() {}
    public open func foo5(): Unit {
        println("A::foo5 common")
    }
}

common public class A2 <: A {
    public init() {}
}

common public class B <: I {
    public init() {}
}

public func runCommonA(a: A) {
    a.foo5()
}

public func runCommonA2(a: A2) {
    a.foo5()
}
