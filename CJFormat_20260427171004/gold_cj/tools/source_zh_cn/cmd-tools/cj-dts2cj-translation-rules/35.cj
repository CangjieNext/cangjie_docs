public class ObjectTypes<U, T> {
    protected ObjectTypes(public var typeLiteral10: JSValue /* FIXME: `{ x: number; y: U }` */ , public var typeLiteral20: JSValue /* FIXME: `{ [number]: string; [symbol]: T }` */ ,
        public var typeLiteral30: JSValue /* FIXME: `{ () => void; (number: any) => string }` */ ) {}

    public func toJSValue(context: JSContext): JSValue {
        let obj = context.object()
        obj["typeLiteral10"] = typeLiteral10
        obj["typeLiteral20"] = typeLiteral20
        obj["typeLiteral30"] = typeLiteral30
        obj.toJSValue()
    }

    public static func fromJSValue<U, T>(context: JSContext, input: JSValue): ObjectTypes<U, T> {
        let obj = input.asObject()
        ObjectTypes(
            JSValue /* FIXME: `{ x: number; y: U }` */ .fromJSValue(context, obj["typeLiteral10"]),
            JSValue /* FIXME: `{ [number]: string; [symbol]: T }` */ .fromJSValue(context, obj["typeLiteral20"]),
            JSValue /* FIXME: `{ () => void; (number: any) => string }` */ .fromJSValue(context, obj["typeLiteral30"])
        )
    }
}
