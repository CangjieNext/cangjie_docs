// a.cj
package a
public class C1<T> {}
class C2 {}
public let v1 = C1<C2>() // Error, public declaration v1 cannot use internal type C2.