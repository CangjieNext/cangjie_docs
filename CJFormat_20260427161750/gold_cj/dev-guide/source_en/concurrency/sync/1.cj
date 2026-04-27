class AtomicInt8 {
    public func load(): Int8
    public func store(val: Int8): Unit
    public func swap(val: Int8): Int8
    public func compareAndSwap(old: Int8, new: Int8): Bool
    public func fetchAdd(val: Int8): Int8
    public func fetchSub(val: Int8): Int8
    public func fetchAnd(val: Int8): Int8
    public func fetchOr(val: Int8): Int8
    public func fetchXor(val: Int8): Int8
}
