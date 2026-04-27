// package c
package c

import a.Foo
import b.I1

main() {
    let x: Foo = Foo()
    x.f1() // OK, because f1 is a member of I1.
    x.f2() // error, I2 is not imported
    x.f3() // error, f3 not found
}
