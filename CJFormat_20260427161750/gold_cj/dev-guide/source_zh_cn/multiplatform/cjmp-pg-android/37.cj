package java.lang

@JavaMirror["java.lang.Object"]
open class JObject {
    public open func equals(obj: ?JObject): Bool

    public func hashCode(): Int64

    @ForeignName["hashCode"]
    public open func hashCode32(): Int32

    public func toString(): String

    @ForeignName["toString"]
    public open func toJString(): JString

    public func wait(timeoutMillis: Int64): Unit
    public func wait(timeoutMillis: Int64, nanos: Int32): Unit
    public func wait(): Unit
    public func notifyAll(): Unit
    public func notify(): Unit
}
