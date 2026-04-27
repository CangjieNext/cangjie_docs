// package a.b
package a.b

private interface I1 {}
internal interface I2 {}
protected interface I3 {}

extend Int64 <: I1 & I2 & I3 {}

public class Foo<T> {}
// The extension will not be exported
extend<T> Foo<T> where T <: I1 {
    public func f1() {}
}
// The extension will be exported, and only packages that import both Foo and I2 will be able to access it.
extend<T> Foo<T> where T <: I2 {
    public func f2() {}
}
// The extension will be exported, and only packages that import both Foo and I3 will be able to access it.
extend<T> Foo<T> where T <: I3 {
    public func f3() {}
}
// The extension will not be exported. The I1 with the lowest access level determines the export.
extend<T> Foo<T> where T <: I1 & I2 & I3 {
    public func f4() {}
}
// The extension is exported. Only the package that imports Foo, I2, and I3 can access the extension.
extend<T> Foo<T> where T <: I2 & I3 {
    public func f5() {}
}

// package a.c
package a.c
import a.b.*

main() {
    Foo<Int64>().f1() // Cannot access.
    Foo<Int64>().f2() // Cannot access. Visible only for sub-pkg.
    Foo<Int64>().f3() // OK.
    Foo<Int64>().f4() // Cannot access.
    Foo<Int64>().f5() // Cannot access. Visible only for sub-pkg.
}

// package a.b.d
package a.b.d
import a.b.*

main() {
    Foo<Int64>().f1() // Cannot access.
    Foo<Int64>().f2() // OK.
    Foo<Int64>().f3() // OK.
    Foo<Int64>().f4() // Cannot access.
    Foo<Int64>().f5() // OK.
}