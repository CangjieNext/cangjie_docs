@JavaImpl
public class BooleanNode <: Node {
    private let flag: Bool
    public init(id: Int32, flag: Bool) {
        super.init(id)
        this.flag = flag
    }
    public func getFlag(): Bool {
        flag
    }
}