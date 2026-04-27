public var t1: () -> Unit = {=>} // OK.

func f1(): Unit {}

public let t2 = f1 // OK.

public func f2() // OK.
{
    return f1
}
