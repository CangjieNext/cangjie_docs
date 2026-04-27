import std.reflect.*

public class Foo {
    public let _p1: Int64 = 1
    public prop p1: Int64 {
        get() {
            _p1
        }
    }
    public var _p2: Int64 = 2
    public mut prop p2: Int64 {
        get() {
            _p2
        }
        set(v) {
            _p2 = v
        }
    }
}

main(): Unit {
    let obj = Foo()
    let info = TypeInfo.of(obj)
    let instanceProps = info.instanceProperties.toArray()
    println("Instance member properties of obj include ${instanceProps}")
    let PropInfo1 = info.getInstanceProperty("p1")
    let PropInfo2 = info.getInstanceProperty("p2")

    println((PropInfo1.getValue(obj) as Int64).getOrThrow())
    println((PropInfo2.getValue(obj) as Int64).getOrThrow())
    if (PropInfo1.isMutable()) {
        PropInfo1.setValue(obj, 10)
    }
    if (PropInfo2.isMutable()) {
        PropInfo2.setValue(obj, 20)
    }
    println((PropInfo1.getValue(obj) as Int64).getOrThrow())
    println((PropInfo2.getValue(obj) as Int64).getOrThrow())
    return
}
