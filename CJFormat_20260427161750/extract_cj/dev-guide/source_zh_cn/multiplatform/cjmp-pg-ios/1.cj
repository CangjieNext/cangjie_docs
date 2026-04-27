@ObjCMirror
public open class Node <: NSObject {
    @ForeignName["initWith:"]
    public init(x: Int32)
    public open func getX(): Int32
}