struct RecordData<T> {
    var a: T
    public init(x: T) {
        a = x
    }
}

type RD<T> = RecordData<T>

main(): Int64 {
    var struct1: RD<Int32> = RecordData<Int32>(2)
    return 1
}