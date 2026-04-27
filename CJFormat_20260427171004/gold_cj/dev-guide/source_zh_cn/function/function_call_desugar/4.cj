func f(x: Int64): Float64 {
    Float64(x)
}

func g(x: Float64): Float64 {
    x
}

var fg = f ~> g // The same as { x: Int64 => g(f(x)) }
