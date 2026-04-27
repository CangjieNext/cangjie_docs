public enum ARK1 {
    | NULL
    | NUMBER(Float64)
    | STRING(String)
    | BOOLEAN(Bool)
    | BYTEARRAY(Array<UInt8>)
    | FLOAT32ARRAY(Array<Float32>)
    | BIGINT(BigInt)

    public func toJSValue(context: JSContext): JSValue {
        match(this) {
            case NULL => context.null().toJSValue()
            case NUMBER(x) => context.number(x).toJSValue()
            case STRING(x) => context.string(x).toJSValue()
            case BOOLEAN(x) => context.boolean(x).toJSValue()
            case BYTEARRAY(x) => context.global["Uint8Array"].asClass().new(x.toJSValue(context))
            case FLOAT32ARRAY(x) => let buffer = context.arrayBuffer(acquireArrayRawData(x), x.size, { pt => releaseArrayRawData(pt)})
context.global["Float32Array"].asClass().new(buffer.toJSValue())
            case BIGINT(x) => context.bigint(x).toJSValue()
        }
    }
}

public enum ARK2 {
    | ARK1(x)
    | VOID(Unit)

    public func toJSValue(context: JSContext): JSValue {
        match(this) {
            case ARK1(x) => x.toJSValue(context)
        }
    }
}