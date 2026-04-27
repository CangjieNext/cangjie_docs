func f(a: Int64, b!: Int64 = 2): Unit {}

var a = 1 |> {x: Int64 => f(x, b: 3)}  // OK