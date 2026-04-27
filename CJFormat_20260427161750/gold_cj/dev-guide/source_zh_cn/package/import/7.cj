// pkgb/b.cj
package pkgb

import pkga.*

func f(a: Int32) {} // f3

struct R {} // R2

func bar() {
    R() // OK, R2 shadows R1.
    f(1) // OK, invoke f3 in current package.
    f(true) // OK, invoke f2 in the pkga
}
