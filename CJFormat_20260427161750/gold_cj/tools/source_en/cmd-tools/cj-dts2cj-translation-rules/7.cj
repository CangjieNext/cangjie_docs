public class Person {
    protected Person(let arkts_object: JSObject) {}

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

    /**
     * @brief greet(): String
     */
    public func greet(): String {
        jsObjApiCall<String>(arkts_object, "greet", emptyArg)
    }

    func toJSValue(context: JSContext): JSValue {
        arkts_object.toJSValue()
    }

    static func fromJSValue(context: JSContext, input: JSValue): Person {
        Person(input.asObject())
    }
}
