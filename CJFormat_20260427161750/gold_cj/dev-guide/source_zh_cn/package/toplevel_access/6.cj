// a.cj
package a

class C1 {}

func f1(a1: C1) {
    return 0
}

public func f2(a1: Int8) // OK.
{
    var v1 = C1()
    return 0
}

public let v1 = f1(C1()) // OK.

public class C2 // OK.
{
    var v2 = C1()
}
