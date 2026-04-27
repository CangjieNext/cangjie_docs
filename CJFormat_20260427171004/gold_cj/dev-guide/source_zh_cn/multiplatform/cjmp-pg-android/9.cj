package cj

import interoplib.interop.*

public struct Vector {
    private var x: Int32 = 0
    private var y: Int32 = 0

    public init(x: Int32, y: Int32) {
        this.x = x
        this.y = y
    }

    public func add(v: Vector): Vector {
        let res = Vector(x + v.x, y + v.y)
        print("cj: (${x}, ${y}) + (${v.x}, ${v.y}) = (${res.x}, ${res.y})\n", flush: true)
        return res
    }

    public static func dump(v: Vector): Unit {
        print("cj: Hello from static func in cj.Vector (${v.x}, ${v.y})\n", flush: true)
    }
}
