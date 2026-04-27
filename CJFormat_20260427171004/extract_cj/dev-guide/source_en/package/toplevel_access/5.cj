// a.cj
package a
interface I {}
public class B<T> where T <: I {}  // Error, public declaration B cannot use internal type I.