// pkga/a.cj
package pkga    // Error, packages pkga pkgb are in circular dependencies.
import pkgb.*

class C {}
public struct R {}

// pkgb/b.cj
package pkgb

import pkga.*

// pkgc/c1.cj
package pkgc

import pkga.C // Error, 'C' is not accessible in package 'pkga'.
import pkgc.f1 // Error, package 'pkgc' should not import itself.

public func f1() {}

// pkgc/c2.cj
package pkgc

import pkga.R // OK, R is an external top-level declaration of package pkga.
import pkga

func f2() {
    /* OK, the imported declaration is visible to all source files of the same package
     * and accessing import declaration by its name is supported.
     */
    R()

    // OK, accessing imported declaration by fully qualified name is supported.
    pkga.R()

    // OK, the declaration of current package can be accessed directly.
    f1()
}