package cjworld // Same package name

import interoplib.objc.* // Always required

@ObjCImpl
public class A <: M {
    public init() {
        super()
    }

    @ForeignName["foo"]
    public override func foo(): Unit {
        println("Hello from overridden A.foo()")
    }
}
