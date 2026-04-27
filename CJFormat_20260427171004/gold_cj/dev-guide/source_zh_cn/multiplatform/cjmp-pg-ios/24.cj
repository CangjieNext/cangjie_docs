@ObjCMirror
open class Foo <: NSObject {}

@ObjCMirror
open class Bar <: Foo {}

@ObjCMirror
open class C <: NSObject {
    open func get(): Option<Foo>
}

@ObjCMirror
open class D <: C {
    // open func get(): Option<Bar>  // Error, `Option<T>` is not covariant by T
    open func get(): Option<Foo> // OK, but the return type is lowered
}
