type A = B
class B {
    static var b : Int32 = 0
    static func foo() {}
}
func foo() {
    A.foo() // Use A to access static method in class B
    A.b
}