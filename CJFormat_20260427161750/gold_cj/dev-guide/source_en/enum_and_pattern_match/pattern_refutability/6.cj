enum E1 {
    A(Int64)
}

enum E2 {
    B(Int64) | C(Int64)
}

func enumPat1(x: E1) {
    match (x) {
        case A(1) => "A(1)"
        case A(a) => "A(${a})"
    }
}

func enumPat2(x: E2) {
    match (x) {
        case B(b) => "B(${b})"
        case C(c) => "C(${c})"
    }
}
