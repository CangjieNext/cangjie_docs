struct Rectangle {
    public var width: Int64
    public var height: Int64

    public init(width: Int64, height: Int64) {
        this.width = width
        this.height = height
    }

    public func area() {
        width * height
    }
}
let r = Rectangle(10, 20)
let width = r.width   // width = 10
let height = r.height // height = 20
let a = r.area()      // a = 200