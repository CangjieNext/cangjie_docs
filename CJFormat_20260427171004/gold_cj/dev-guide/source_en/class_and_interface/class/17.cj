package a

public open class Rectangle {
    public var width: Int64
    protected var height: Int64
    private var area: Int64
    public init(width: Int64, height: Int64) {
        this.width = width
        this.height = height
        this.area = this.width * this.height
    }
    init(width: Int64, height: Int64, multiple: Int64) {
        this.width = width
        this.height = height
        this.area = width * height * multiple
    }
}

func samePkgFunc() {
    var r = Rectangle(10, 20) // OK: constructor 'Rectangle' can be accessed here
    r.width = 8 // OK: public 'width' can be accessed here
    r.height = 24 // OK: protected 'height' can be accessed here
    r.area = 30 // Error, private 'area' cannot be accessed here
}
