class Rectangle {
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

main() {
    let r = Rectangle(10, 20) // r.width = 10, r.height = 20
    r.width = 8               // r.width = 8
    r.height = 24             // r.height = 24
    let a = r.area()          // a = 192
}