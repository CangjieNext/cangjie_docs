// main.cj
import p1 as A
import p1 as B
import p2.f3 as f  // OK
import pkgc.f1 as a
import pkgc.f1 as b // OK

func f(a: Int32) {}

main() {
    A.f1()  // OK, package name conflict is resolved by renaming package name.
    B.f2()  // OK, package name conflict is resolved by renaming package name.
    p1.f1() // Error, the original package name cannot be used.
    a()     // OK.
    b()     // OK.
    pkgc.f1()    // Error, the original name cannot be used.
}