class Foo {
    public open func f() {}
    static func h() {}
}

extend Foo {
    public override func f() {} // Error
    public open func g() {} // Error
    redef static func h() {} // Error
}