func f(a!: Int64): Unit {}

var x = 1 |> {x: Int64 => f(a: x)} // OK
