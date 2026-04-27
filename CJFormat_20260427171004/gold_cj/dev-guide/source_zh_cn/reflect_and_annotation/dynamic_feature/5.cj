import std.reflect.*

public class Foo {
    public static var param1 = 20
    public var param2 = 10
}

main(): Unit {
    let obj = Foo()
    let info = TypeInfo.of(obj)
    let staticVarInfo = info.getStaticVariable("param1")
    let instanceVarInfo = info.getInstanceVariable("param2")
    println("成员变量初始值")
    print("Foo 的静态成员变量 ${staticVarInfo} = ")
    println((staticVarInfo.getValue() as Int64).getOrThrow())
    print("obj 的实例成员变量 ${instanceVarInfo} = ")
    println((instanceVarInfo.getValue(obj) as Int64).getOrThrow())
    println("更改成员变量")
    staticVarInfo.setValue(8)
    instanceVarInfo.setValue(obj, 25)
    print("Foo 的静态成员变量 ${staticVarInfo} = ")
    println((staticVarInfo.getValue() as Int64).getOrThrow())
    print("obj 的实例成员变量 ${instanceVarInfo} = ")
    println((instanceVarInfo.getValue(obj) as Int64).getOrThrow())
    return
}
