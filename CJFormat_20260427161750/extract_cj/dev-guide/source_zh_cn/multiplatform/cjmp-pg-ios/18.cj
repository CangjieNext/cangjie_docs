@ObjCMirror
public open class A <: ObjCId {
    public static func foo()
}

@ObjCMirror
public open class B <: A {
    public open func fooInstance()
    public static func barStatic()
    public open func bar()
}