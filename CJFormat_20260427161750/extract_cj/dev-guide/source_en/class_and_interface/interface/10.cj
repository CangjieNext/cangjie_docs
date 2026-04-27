import std.collection.ArrayList
interface M {
    func foo<T>(a: T): T
    static func toString<T>(b: ArrayList<T>): String where T <: ToString
}
class C <: M {
    public func foo<S>(a: S): S { // implements M::foo, names of generic parameters do not matter
        a
    }
    public static func toString<T>(b: ArrayList<T>) where T <: ToString {
        var res = ""
        for (s in b) {
            res += s.toString()
        }
        res
    }
}