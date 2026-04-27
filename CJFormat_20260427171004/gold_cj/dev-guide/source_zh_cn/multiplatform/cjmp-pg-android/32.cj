@JavaMirror
public open class Foo {}

@JavaMirror
public open class Bar <: Foo {}

@JavaMirror
public interface C {
    public open func get(): Foo
}

@JavaMirror
public interface D <: C {
    public open override func get(): Bar // 此处存在返回类型协变
}
