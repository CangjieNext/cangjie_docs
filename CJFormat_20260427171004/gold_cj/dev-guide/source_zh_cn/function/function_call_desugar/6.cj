func h1<T>(x: T): T {
    x
}

func h2<T>(x: T): T {
    x
}

var hh = h1<Int64> ~> h2<Int64> // The same as { x: Int64 => h2<Int64>(h1<Int64>(x)) }
