package cj

import interoplib.interop.*

public interface Valuable {
    public func value(): Int
}

public open class Singleton <: Valuable {
    private let _v: Int
    public init (v: Int) { _v = v }
    public func value(): Int { _v }
}

public class Zero <: Singleton {
    public init() { super(0) }
}