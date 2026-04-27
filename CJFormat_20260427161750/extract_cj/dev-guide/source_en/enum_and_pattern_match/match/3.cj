enum T {
    | Red | Green | Blue | ...
}
func foo(a: T) {
    match (a) {
        case Red => 0
        case Green => 1
        case Blue => 2
        case _ => -1
    }
}

func bar(a: T) {
    match (a) {
        case Red => 0
        case k => -1 // simple binding pattern
    }
}

func baz(a: T) {
    match (a) {
        case Red => 0
        case k: T => -1 // binding pattern with nested type pattern
    }
}