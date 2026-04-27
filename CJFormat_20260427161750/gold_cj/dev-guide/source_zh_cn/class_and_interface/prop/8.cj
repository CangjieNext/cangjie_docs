interface I1 {
    mut prop size: Int64
}

interface I2 {
    func getSize(): Int64
    func setSize(value: Int64): Unit
}

class C <: I1 & I2 {
    private var mySize = 0

    public mut prop size: Int64 {
        get() {
            mySize
        }
        set(value) {
            mySize = value
        }
    }

    public func getSize() {
        mySize
    }

    public func setSize(value: Int64) {
        mySize = value
    }
}

main() {
    let a: I1 = C()
    a.size = 5
    println(a.size)

    let b: I2 = C()
    b.setSize(5)
    println(b.getSize())
}
