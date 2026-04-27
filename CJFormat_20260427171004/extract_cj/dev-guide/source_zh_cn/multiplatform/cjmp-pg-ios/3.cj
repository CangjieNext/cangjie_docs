@ObjCImpl
public class BooleanNode <: Node {
    private let _flag: Bool
    public init(x: Int32, flag: Bool) {
        super.init(x)
        this._flag = flag
    }
    public func flag(): Bool {
        _flag
    }
}