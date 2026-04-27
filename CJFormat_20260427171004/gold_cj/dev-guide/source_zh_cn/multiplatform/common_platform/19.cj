// specific
package cmp

specific public interface I {
    func foo5(): Unit {
        println("I::foo5 specific")
    }
}

specific public open class A <: I {}

specific public class A2 <: A {
    public func foo5(): Unit {
        println("A2::foo5 specific")
    }
}

specific public class B <: I {}

public class C <: I {}

public func runPlatformI(a: I) {
    a.foo5()
}

public func runPlatformA(a: A) {
    a.foo5()
}

public func runPlatformA2(a: A2) {
    a.foo5()
}
