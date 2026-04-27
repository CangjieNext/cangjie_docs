struct R {
    public var a: Int64
    public init(a: Int64) {
        this.a = a
    }
}

let r = R(100)
let x = Some(r)
let y = Option<R>.None
let r1 = x?.a   // r1 = Option<Int64>.Some(100)
let r2 = y?.a   // r2 = Option<Int64>.None

class C {
    var item: Int64 = 100
}
let c = C()
let c1 = Option<C>.Some(c)
let c2 = Option<C>.None
func test1() {
    c1?.item = 200             // c.item = 200
    c2?.item = 300             // no effect
}