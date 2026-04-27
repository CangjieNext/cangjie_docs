public class Node {
    private let next: ?Node
    public init() {
        next = None
    }
    public init(next: Node) { /* Pure Cangjie */
        this.next = Some(next)
    }
}
