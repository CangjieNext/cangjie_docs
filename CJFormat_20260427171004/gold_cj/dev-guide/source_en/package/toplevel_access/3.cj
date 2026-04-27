// a.cj
package a

class C {}

public let v1: C = C() // Error, public declaration v1 cannot use internal type C.
public let v2 = C() // Error, public declaration v2 cannot use internal type C.
