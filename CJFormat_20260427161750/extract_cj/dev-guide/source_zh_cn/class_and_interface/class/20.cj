class Rectangle {
    let width: Int64
    let height: Int64

    public init(width: Int64, height: Int64) {
        this.width = width
        this.height = height
    }

    public func area() {
        this.width * this.height
    }
}

main() {
    let r = Rectangle(10, 20) // r.width = 10, r.height = 20
    let width = r.width       // width = 10
    let height = r.height     // height = 20
    let a = r.area()          // a = 200
}