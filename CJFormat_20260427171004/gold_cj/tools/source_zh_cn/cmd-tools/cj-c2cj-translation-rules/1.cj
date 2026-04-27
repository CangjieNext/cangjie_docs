@C
public struct _cjbind_ty_1 {
    public let x: Int32
    public let y: Int32

    public init(x: Int32, y: Int32) {
        this.x = x
        this.y = y
    }
}

@C
public struct Point {
    public let __cjbind_anon_1: _cjbind_ty_1
    public let z: Int32

    public init(__cjbind_anon_1: _cjbind_ty_1, z: Int32) {
        this.__cjbind_anon_1 = __cjbind_anon_1
        this.z = z
    }
}

@C
public struct Person {
    public let age: Int32

    public init(age: Int32) {
        this.age = age
    }
}

@C
public struct Point3D {
    public let x: Int64
    public let y: Int64
    public let z: Int64

    public init(x: Int64, y: Int64, z: Int64) {
        this.x = x
        this.y = y
        this.z = z
    }
}
