func foo(p: Point): Point {
    p.x += 10
    return p
}

open class Point {
    var x: Int64 = 0
    public init (a: Int64) {
        x = a
    }
}

main() {
    var a = Point(9)    // a.x == 9
    var b = 2

    foo(a).x += (b + b) // a.x == 23
    println(a.x)
}