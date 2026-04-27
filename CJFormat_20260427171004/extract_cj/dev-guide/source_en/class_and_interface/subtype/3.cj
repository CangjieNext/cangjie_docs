open class C1 {}
class C2 <: C1 {}

open class C3 {}
class C4 <: C3 {}

let t1: (C1, C3) = (C2(), C4()) // OK
let t2: (C3, C1) = (C4(), C2()) // OK