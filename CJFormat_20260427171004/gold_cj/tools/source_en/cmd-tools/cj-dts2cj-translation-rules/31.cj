public class arrayInterface {
    protected arrayInterface(public var arrayType1: Array<Float64>, public var arrayType2: Array<UInt8>,
        public var arrayType3: Array<UInt8>, public var arrayType4: Array<Float32>) {}

    public func toJSValue(context: JSContext): JSValue {
        let obj = context.object()
        obj["arrayType1"] = toJSArray(context, arrayType1)
        obj["arrayType2"] = toJSArray(context, arrayType2, {ctx: JSContext, val: UInt8 => val.toJSValue(ctx)})
        obj["arrayType3"] = toJSArray(context, arrayType3, {ctx: JSContext, val: UInt8 => val.toJSValue(ctx)})
        obj["arrayType4"] = toJSArray(context, arrayType4, {ctx: JSContext, val: Float32 => val.toJSValue(ctx)})
        obj.toJSValue()
    }

    public static func fromJSValue(context: JSContext, input: JSValue): arrayInterface {
        let obj = input.asObject()
        arrayInterface(
            fromJSArray<Float64>(context, obj["arrayType1"]),
            fromJSArray(context, obj["arrayType2"], {ctx: JSContext, val: JSValue => UInt8.fromJSValue(ctx, val)}),
            fromJSArray(context, obj["arrayType3"], {ctx: JSContext, val: JSValue => UInt8.fromJSValue(ctx, val)}),
            fromJSArray(context, obj["arrayType4"], {ctx: JSContext, val: JSValue => Float32.fromJSValue(ctx, val)})
        )
    }
}
