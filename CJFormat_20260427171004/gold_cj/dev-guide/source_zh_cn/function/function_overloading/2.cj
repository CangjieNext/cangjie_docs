// Scenario 2

interface I1 {}

interface I2 {}

func f1<X, Y>(a: X, b: Y) {}

func f1<Y, X>(a: X, b: Y) {} // OK: after rename generic type parameter, it will be 'func f1<X, Y>(a: Y, b: X)'

func f2<T>(a: T) where T <: I1 {} // Error, not overloading

func f2<T>(a: T) where T <: I2 {} // Error, not overloading
