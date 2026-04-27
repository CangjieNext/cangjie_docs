// specific part
specific public abstract class A {
    specific public func a(): Int {
        4
    }
    specific public open func c(): Int {
        5
    }
    specific public func d(): Int {
        6
    }
    specific public open func e(): Int {
        7
    }
    specific public abstract func f(): Int

    specific public open prop prop_a: Int {
        get() {
            2
        }
    }
}
