// a.cj
package p1
public class C {}

// b.cj
package p2
public class C {}

// main1.cj
package pkga
import p1.C
import p2.C

main() {
    let _ = C() // Error
}

// main2.cj
package pkgb
import p1.C as C1
import p2.C as C2

main() {
    let _ = C1() // OK
    let _ = C2() // OK
}

// main3.cj
package pkgc
import p1
import p2

main() {
    let _ = p1.C() // OK
    let _ = p2.C() // OK
}