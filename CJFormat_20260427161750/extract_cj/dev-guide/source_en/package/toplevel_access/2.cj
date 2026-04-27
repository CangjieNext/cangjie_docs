// a.cj
package a
class C {}
public func f1(a1: C) // Error, public declaration f1 cannot use internal type C.
{
    return 0
}
public func f2(a1: Int8): C // Error, public declaration f2 cannot use internal type C.
{
    return C()
}
public func f3 (a1: Int8) // Error, public declaration f3 cannot use internal type C.
{
    return C()
}