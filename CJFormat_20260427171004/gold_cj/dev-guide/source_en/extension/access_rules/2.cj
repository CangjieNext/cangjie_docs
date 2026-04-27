package p1

public open class A {}

extend A {
    public func f1() {}
    protected func f2() {}
    private func f3() {}
    static func f4() {}
}

main() {
    A.f4()
    var a = A()
    a.f1()
    a.f2()
}
