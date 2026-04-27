open class A {
    private var valueX = 0
    private static var valueY = 0

    public open prop x: Int64 {
        get() { valueX }
    }

    public static mut prop y: Int64 {
        get() { valueY }
        set(v) {
            valueY = v
        }
    }
}
class B <: A {
    private var valueX2 = 0
    private static var valueY2 = 0

    public override prop x: Int64 {
        get() { valueX2 }
    }

    public redef static mut prop y: Int64 {
        get() { valueY2 }
        set(v) {
            valueY2 = v
        }
    }
}