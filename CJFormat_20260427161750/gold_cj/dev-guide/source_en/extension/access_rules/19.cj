// package c
package c

import a.Foo
import b.I

func test() {
    let a = Foo()
    a.f() // OK
    a.g() // OK
}
