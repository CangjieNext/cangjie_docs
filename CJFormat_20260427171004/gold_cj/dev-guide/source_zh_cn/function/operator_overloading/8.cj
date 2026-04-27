open class MyClass {
    var x: Int64 = 0
    public init(a: Int64) {
        x = a
    }

    public operator func +(right: MyClass): Int64 { // The above rules are not met
        this.x + right.x
    }
}

main() {
    var a = MyClass(5)
    var b = MyClass(3)
    a += b // Error, type incompatible in this compound assignment expression
}
