class C {
    public static var a: Int32 = 0
    public static func foo() {
        a++ // OK
        return a
    }
}

var globalV1 = 0

func countGlobalV1() {
    globalV1++
    C.a = 99
    let g = C.foo // OK
}

func g() {
    let f = countGlobalV1 // OK
    f()
}
