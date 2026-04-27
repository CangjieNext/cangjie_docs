public class G<T> {
    private let _t: T
    public init(t: T) {
        _t = t
    }
    public func get(): T {
        _t
    }
}
