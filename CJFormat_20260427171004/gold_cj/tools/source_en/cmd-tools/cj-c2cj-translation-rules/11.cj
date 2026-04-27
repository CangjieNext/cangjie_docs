@C
public struct FlexibleString {
    public let length: Int32
    public let data: CPointer<UInt8>

    public init(length: Int32, data: CPointer<UInt8>) {
        this.length = length
        this.data = data
    }
}
