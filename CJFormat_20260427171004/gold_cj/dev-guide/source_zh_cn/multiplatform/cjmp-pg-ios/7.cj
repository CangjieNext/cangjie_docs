package cj

import interoplib.objc.*

public struct Vector {
    let x: Int32
    let y: Int32

    public init(x: Int32, y: Int32) {
        this.x = x
        this.y = y
    }

    public func add(v: Vector): Vector {
        Vector(x + v.x, y + v.y)
    }
}
