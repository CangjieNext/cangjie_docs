public class BasicTypes {
    protected BasicTypes(public var numberKeyword: Float64, public var stringKeyword: String,
        public var booleanKeyword: Bool, public var bigintKeyword: BigInt, public var objectKeyword: JSValue /* FIXME: `object` */ ,
        public var symbolKeyword: JSValue /* FIXME: `symbol` */ , public var voidKeyword: Unit, public var undefinedKeyword: JSValue /* FIXME: `undefined` */ ,
        public var anyKeyword: Any, public var unknownKeyword: JSValue /* FIXME: `unknown` */ , public var neverKeyword: JSValue /* FIXME: `never` */ ) {}

    public func toJSValue(context: JSContext): JSValue {
        let obj = context.object()
        obj["numberKeyword"] = numberKeyword.toJSValue(context)
        obj["stringKeyword"] = stringKeyword.toJSValue(context)
        obj["booleanKeyword"] = booleanKeyword.toJSValue(context)
        obj["bigintKeyword"] = context.bigint(bigintKeyword).toJSValue(context)
        obj["objectKeyword"] = objectKeyword
        obj["symbolKeyword"] = symbolKeyword
        obj["voidKeyword"] = voidKeyword.toJSValue(context)
        obj["undefinedKeyword"] = undefinedKeyword
        obj["anyKeyword"] = anyKeyword.toJSValue(context)
        obj["unknownKeyword"] = unknownKeyword
        obj["neverKeyword"] = neverKeyword
        obj.toJSValue()
    }

    public static func fromJSValue(context: JSContext, input: JSValue): BasicTypes {
        let obj = input.asObject()
        BasicTypes(
            Float64.fromJSValue(context, obj["numberKeyword"]),
            String.fromJSValue(context, obj["stringKeyword"]),
            Bool.fromJSValue(context, obj["booleanKeyword"]),
            obj["bigintKeyword"].asBigInt(context).toBigInt(),
            JSValue /* FIXME: `object` */ .fromJSValue(context, obj["objectKeyword"]),
            JSValue /* FIXME: `symbol` */ .fromJSValue(context, obj["symbolKeyword"]),
            Unit.fromJSValue(context, obj["voidKeyword"]),
            JSValue /* FIXME: `undefined` */ .fromJSValue(context, obj["undefinedKeyword"]),
            Any.fromJSValue(context, obj["anyKeyword"]),
            JSValue /* FIXME: `unknown` */ .fromJSValue(context, obj["unknownKeyword"]),
            JSValue /* FIXME: `never` */ .fromJSValue(context, obj["neverKeyword"])
        )
    }
}
