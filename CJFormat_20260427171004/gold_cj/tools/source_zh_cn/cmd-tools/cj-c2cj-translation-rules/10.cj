@C
public struct OpaqueType {
    init() {
        throw Exception("This type should be implemented by user")
    }
}

foreign func create_opaque(initial_value: Int32): CPointer<OpaqueType>

foreign func set_value(obj: CPointer<OpaqueType>, value: Int32): Unit

foreign func get_value(obj: CPointer<OpaqueType>): Int32

foreign func destroy_opaque(obj: CPointer<OpaqueType>): Unit
