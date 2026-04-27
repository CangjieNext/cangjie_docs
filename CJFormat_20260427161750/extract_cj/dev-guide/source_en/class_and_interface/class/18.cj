package b
import a.*

public class Cuboid <: Rectangle {
    private var length: Int64
    public init(width: Int64, height: Int64, length: Int64) {
        super(width, height)
        this.length = length
    }
    public func volume() {
        this.width * this.height * this.length // OK: protected 'height' can be accessed here
    }
}

main() {
    var r = Rectangle(10, 20, 2) // Error, Rectangle has no `public` constructor with three parameters
    var c = Cuboid(20, 20, 20)
    c.width = 8               // OK: public 'width' can be accessed here
    c.height = 24             // Error, protected 'height' cannot be accessed here
    c.area = 30               // Error, private 'area' cannot be accessed here
}