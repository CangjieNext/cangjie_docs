
public open class AutoGenType0 {

    protected AutoGenType0(public var : String,
    public var : String) {}


    public open func toJSValue(context: JSContext): JSValue {
        let obj = context.object()
        obj["city"] = .toJSValue(context)
        obj["zipCode"] = .toJSValue(context)
        obj.toJSValue()
    }

    public static func fromJSValue(context: JSContext, input: JSValue): AutoGenType0 {
        let obj = input.asObject()
        AutoGenType0(
        String.fromJSValue(context, obj["city"]),
        String.fromJSValue(context, obj["zipCode"])
        )
    }

}


public open class UserProfile {

    protected UserProfile(public var id: Float64,
    public var name: String,
    public var address: AutoGenType0) {}


    public open func toJSValue(context: JSContext): JSValue {
        let obj = context.object()
        obj["id"] = id.toJSValue(context)
        obj["name"] = name.toJSValue(context)
        obj["address"] = address.toJSValue(context)
        obj.toJSValue()
    }

    public static func fromJSValue(context: JSContext, input: JSValue): UserProfile {
        let obj = input.asObject()
        UserProfile(
        Float64.fromJSValue(context, obj["id"]),
        String.fromJSValue(context, obj["name"]),
        AutoGenType0.fromJSValue(context, obj["address"])
        )
    }

}