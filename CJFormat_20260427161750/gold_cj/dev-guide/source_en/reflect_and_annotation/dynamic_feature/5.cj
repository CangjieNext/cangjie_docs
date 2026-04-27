import std.collection.*
import std.reflect.*

class A<T> {
    A(public let t: T) {}
}

class B<T> {
    B(public let t: T) {}
}

main() {
    let aInfo: TypeInfo = TypeInfo.get("default.A<Int64>") // Error,`default.A<Int64>` is not instantiated，will throw InfoNotFoundException
    let b: B<Int64> = B<Int64>(1)
    let bInfo: TypeInfo = TypeInfo.get("default.B<Int64>") // OK `default.B<Int64>` has been instantiated.
}
