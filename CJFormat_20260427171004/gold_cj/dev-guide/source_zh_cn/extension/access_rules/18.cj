// package b
package b

import a.Foo

public interface I {
    func g(): Unit
}

extend Foo <: I {
    public func g() {
        this.f() // OK
    }
}
