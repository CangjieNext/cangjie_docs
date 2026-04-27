@JavaMirror
public open class Foo {}

@JavaMirror
public open class Bar <: Foo {}

@JavaMirror
public open interface C {
    public open func get(): ?Foo
}

@JavaMirror
public open interface D <: C {
    // public open func get(): ?Bar    // 错误，Option<T> 对于 T 不协变，?Bar 不是 ?Foo 的子类型
    public open func get(): ?Foo       // 正确，但返回类型被降级了
}