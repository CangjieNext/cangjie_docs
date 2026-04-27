public class GreetingSettings {
    protected GreetingSettings(public var greeting: String, public var duration!: Option<Float64> = None,
        public var color!: Option<String> = None) {}

    public func toJSValue(context: JSContext): JSValue {
        let obj = context.object()
        obj["greeting"] = greeting.toJSValue(context)
        if (let Some(v) <- duration) {
            obj["duration"] = v.toJSValue(context)
        }
        if (let Some(v) <- color) {
            obj["color"] = v.toJSValue(context)
        }
        obj.toJSValue()
    }

    public static func fromJSValue(context: JSContext, input: JSValue): GreetingSettings {
        let obj = input.asObject()
        GreetingSettings(
            String.fromJSValue(context, obj["greeting"]),
            duration: if (obj["duration"].isUndefined()) {
                None
            } else {
                Float64.fromJSValue(context, obj["duration"])
            },
            color: if (obj["color"].isUndefined()) {
                None
            } else {
                String.fromJSValue(context, obj["color"])
            }
        )
    }
}
