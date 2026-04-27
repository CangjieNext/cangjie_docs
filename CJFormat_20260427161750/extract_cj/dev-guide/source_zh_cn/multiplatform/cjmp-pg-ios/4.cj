package cj

import interoplib.objc.*

public struct Vector {
    private let _x: Int32
    private let _y: Int32

    public prop x: Int32 { get() { _x } }
    public prop y: Int32 { get() { _y } }

    public init(x: Int32, y: Int32) {
        _x = x
        _y = y
    }

    public func add(v: Vector): Vector {
        Vector(x + v.x, y + v.y)
    }
}