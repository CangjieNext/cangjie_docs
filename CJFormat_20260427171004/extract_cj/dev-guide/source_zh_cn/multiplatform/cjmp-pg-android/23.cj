@JavaMirror["Outer"]
public open class Outer {
    public init()

    public open func getInner(): ?Outer_Inner
}

@JavaMirror["Outer$Inner"]
public open class Outer_Inner {
    public init(p0: ?Outer)
}