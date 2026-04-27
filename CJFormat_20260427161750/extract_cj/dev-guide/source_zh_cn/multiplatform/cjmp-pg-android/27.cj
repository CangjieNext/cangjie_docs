@JavaMirror["Outer"]
public open class Outer {
    public init()

    public open func getInner(): ?Outer_Inner
}

@JavaMirror["Outer$Static"]       // Original binary name is retained
public open class Outer_Static {  // '$' is replaced with '_'
    public init()
}

@JavaMirror["Outer$Inner"]       // Original binary name is retained
public open class Outer_Inner {  // '$' is replaced with '_'
    public init(p0: ?Outer)      // Extra parameter for enclosing instance
}