package a

public struct Rectangle {
    public var width: Int64
    var height: Int64
    private var area: Int64

    public init(width: Int64, height: Int64, area: Int64) {
        this.width = width
        this.height = height
        this.area = area
    }
}

func samePkgFunc() {
    var r = Rectangle(10, 20, 40)
    r.width = 8 // OK: public 'width' can be accessed here
    r.height = 24 // OK: 'height' has no modifier and can be accessed here
    r.area = 30 // Error, private 'area' can't be accessed here
}
