@ObjCMirror
open class Foo <: NSObject {}

@ObjCMirror
open class Bar <: Foo {}

@ObjCMirror
open class C <: NSObject {
    open func get(): Foo
}

@ObjCMirror
open class D <: C {
    open func get(): Bar // Return type covariance in action
}
