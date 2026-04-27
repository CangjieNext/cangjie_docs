open class Base {
    var name: String = "Alice"
}
class Derived <: Base {
    var age: UInt8 = 18
}

let a = 1 as Int64     // a = Option<Int64>.Some(1)
let b = 1 as String    // b = Option<String>.None

let b1: Base = Base()
let b2: Base = Derived()
let d: Derived = Derived()
let r1 = b1 as Base    // r1 = Option<Base>.Some(b1)
let r2 = b1 as Derived // r2 = Option<Derived>.None
let r3 = b2 as Base    // r3 = Option<Base>.Some(b2)
let r4 = b2 as Derived // r4 = Option<Derived>.Some(b2)
let r5 = d as Base     // r5 = Option<Base>.Some(d)
let r6 = d as Derived  // r6 = Option<Derived>.Some(d)