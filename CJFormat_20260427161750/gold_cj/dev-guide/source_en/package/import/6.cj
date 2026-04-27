// pkga/a.cj
package pkga

public struct R {}            // R1
public func f(a: Int32) {}    // f1
public func f(a: Bool) {} // f2

// pkgb/b.cj
package pkgb
import pkga.*

func f(a: Int32) {}         // f3
struct R {}                 // R2

func bar() {
    R()     // OK, R2 shadows R1.
    f(1)    // OK, invoke f3 in current package.
    f(true) // OK, invoke f2 in the imported package
}