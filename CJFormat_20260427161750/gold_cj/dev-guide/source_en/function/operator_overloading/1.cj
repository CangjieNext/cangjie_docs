open class Point {
    var x: Int64 = 0
    var y: Int64 = 0
    public init(a: Int64, b: Int64) {
        x = a
        y = b
    }

    public operator func -(): Point {
        Point(-x, -y)
    }
    public operator func +(right: Point): Point {
        Point(this.x + right.x, this.y + right.y)
    }
}
