public class Product {
    protected Product(public var price!: Option<Float64> = None) {}

    public func toJSValue(context: JSContext): JSValue {
        let obj = context.object()
        if (let Some(v) <- price) {
            obj["price"] = v.toJSValue(context)
        }
        obj.toJSValue()
    }

    public static func fromJSValue(context: JSContext, input: JSValue): Product {
        let obj = input.asObject()
        Product(price: if (obj["price"].isUndefined()) {
            None
        } else {
            Float64.fromJSValue(context, obj["price"])
        })
    }
}
