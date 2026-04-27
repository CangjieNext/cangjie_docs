public class Car {
    protected Car(let arkts_object: JSObject) {}

    // 只读属性
    public prop brand: String {
        get() {
            checkThreadAndCall<String>(getMainContext()) {
                ctx: JSContext => String.fromJSValue(ctx, arkts_object["brand"])
            }
        }
    }

    public mut prop name: String {
        get() {
            checkThreadAndCall<String>(getMainContext()) {
                ctx: JSContext => String.fromJSValue(ctx, arkts_object["name"])
            }
        }
        set(v) {
            checkThreadAndCall<Unit>(getMainContext()) {
                ctx: JSContext => arkts_object["name"] = v.toJSValue(ctx)
            }
        }
    }

    func toJSValue(context: JSContext): JSValue {
        arkts_object.toJSValue()
    }

    static func fromJSValue(context: JSContext, input: JSValue): Car {
        Car(input.asObject())
    }
}
