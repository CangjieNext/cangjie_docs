public class Node {
    private let _id: Int
    public prop id: Int {
        get() {
            _id
        }
    }
    public init(id: Int) {
        this._id = id
    }
}
