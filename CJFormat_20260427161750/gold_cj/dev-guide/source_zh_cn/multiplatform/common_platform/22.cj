// common part
common public abstract class A {
    init() {}
    common public func a(): Int {
        1
    }
    public open func b(): Int {
        2
    }
    common public open func c(): Int {
        3
    }
    common public func d(): Int
    common public abstract func e(): Int
    common public abstract func f(): Int
    public abstract func g(): Int

    common public open prop prop_a: Int {
        get() {
            1
        }
    }
    common public prop prop_b: Int {
        get() {
            1
        }
    }
    public abstract prop prop_c: Int
}

public class B <: A {
    public func b(): Int {
        a() + 10
    }
    public func c(): Int {
        a() + 20
    }
    public func e(): Int {
        a() + 30
    }
    public func f(): Int {
        a() + 40
    }
    public func g(): Int {
        a() + 50
    }

    public prop prop_c: Int {
        get() {
            10
        }
    }
}
