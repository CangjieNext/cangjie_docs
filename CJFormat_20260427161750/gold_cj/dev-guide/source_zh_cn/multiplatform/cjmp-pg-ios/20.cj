@ObjCMirror
public open class A {
    public open func foo(): Unit

    @ForeignName["foo:"]
    public open func foo(i: Int32): Unit

    @ForeignName["foo:bar:"]
    public open func fooBar(i: Int32, j: Int32): Unit

    @ForeignName["foo:bar:baz:"]
    public open func fooBarBaz(i: Int32, j: Int32, k: Int32): Unit
}
