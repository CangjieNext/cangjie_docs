package cj

public struct Vector {
    private var x: Int32 = 0
    private var y: Int32 = 0

    public init(x: Int32, y: Int32) {
        this.x = x
        this.y = y
    }

    public func add(v: Vector): Vector {
        Vector(x + v.x, y + v.y)
    }
}