// main2.cj
package pkgb

import p1.C as C1
import p2.C as C2

main() {
    let _ = C1() // OK
    let _ = C2() // OK
}
