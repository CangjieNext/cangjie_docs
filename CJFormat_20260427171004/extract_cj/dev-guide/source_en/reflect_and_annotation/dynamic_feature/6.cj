import std.reflect.*

public class Foo {
    public static var param1 = 20
    public var param2 = 10
}

main(): Unit{
    let obj = Foo()
    let info = TypeInfo.of(obj)
    let staticVarInfo = info.getStaticVariable("param1")
    let instanceVarInfo = info.getInstanceVariable("param2")
    println("Initial values of member variables")
    print("Static member variable ${staticVarInfo} of Foo = ")
    println((staticVarInfo.getValue() as Int64).getOrThrow())
    print("Instance member variable ${instanceVarInfo} of obj = ")
    println((instanceVarInfo.getValue(obj) as Int64).getOrThrow())
    println("Modifying member variables")
    staticVarInfo.setValue(8)
    instanceVarInfo.setValue(obj, 25)
    print("Static member variable ${staticVarInfo} of Foo = ")
    println((staticVarInfo.getValue() as Int64).getOrThrow())
    print("Instance member variable ${instanceVarInfo} of obj = ")
    println((instanceVarInfo.getValue(obj) as Int64).getOrThrow())
    return
}