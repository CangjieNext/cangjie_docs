class Rectangle {
    var width: Int64
    var height: Int64

    public init(width: Int64, height: Int64) {
        this.width = width
        this.height = height
    }
    public func area() {
        this.width * this.height
    }
}

main() {
    var r1 = Rectangle(10, 20) // r1.width = 10, r1.height = 20
    var r2 = r1 // r2.width = 10, r2.height = 20
    r1.width = 8 // r1.width = 8
    r1.height = 24 // r1.height = 24
    let a1 = r1.area() // a1 = 192
    let a2 = r2.area() // a2 = 192
}
