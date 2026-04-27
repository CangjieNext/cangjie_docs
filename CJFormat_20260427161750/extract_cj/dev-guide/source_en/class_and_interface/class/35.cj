open class A {}
open class B <: A {}
open class C <: B {}

open class Base {
    public open func foo<T>(a: T): Unit where T <: B {}
    public open func bar<T>(a: T): Unit where T <: B {}
    public static func f<T>(a: T): Unit where T <: B {}
    public static func g<T>(): Unit where T <: B {}
}

class D <: Base {
    public override func foo<T>(a: T): Unit where T <: C {} // Error, stricter constraint
    public override func bar<T>(a: T): Unit where T <: C {} // Error, stricter constraint
    public redef static func f<T>(a: T): Unit where T <: C {} // Error, stricter constraint
    public redef static func g<T>(): Unit where T <: C {} // Error, stricter constraint
}

class E <: Base {
    public override func foo<T>(a: T): Unit where T <: A {} // OK: looser constraint
    public override func bar<V>(a: V): Unit where V <: A {} // OK: looser constraint, names of generic parameters do not matter
    public redef static func f<T>(a: T): Unit where T <: A {} // OK: looser constraint
    public redef static func g<T>(): Unit where T <: A {} // OK: looser constraint
}

class F <: Base {
    public override func foo<T>(a: T): Unit where T <: B {} // OK: same constraint
    public override func bar<V>(a: V): Unit where V <: B {} // OK: same constraint
    public redef static func f<T>(a: T): Unit where T <: B {} // OK: same constraint
    public redef static func g<T>(): Unit where T <: B {} // OK: same constraint
}