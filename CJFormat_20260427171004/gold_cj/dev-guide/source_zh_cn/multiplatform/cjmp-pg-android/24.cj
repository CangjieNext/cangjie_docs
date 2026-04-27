public open class Node {
    @ForeignName["id"]
    public var id_Node: Int32

    public init(arg0: Int32)

    @ForeignName["id"]
    public static func idStatic(arg0: Int64): Int32

    @ForeignName["id"]
    public static func idStatic(arg0: Int16): Int32

    public open func id(): Int32

    public open func id(arg0: Int32): Unit
}