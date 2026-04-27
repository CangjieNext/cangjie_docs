func f(x: Int64): Float64 {
    Float64(x)
}

let lambdaComp = {x: Int64 => x} ~> f // The same as { x: Int64 => f({x: Int64 => x}(x)) }