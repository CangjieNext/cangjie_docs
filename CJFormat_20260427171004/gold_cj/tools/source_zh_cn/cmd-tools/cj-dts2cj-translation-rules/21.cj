public class Box<T> {
    protected Box(let arkts_object: JSObject) {}

    // 属性
    public mut prop value: T {
        get() {
            checkThreadAndCall<T>(getMainContext()) {
                ctx: JSContext => T.fromJSValue(ctx, arkts_object["value"])
            }
        }
        set(v) {
            checkThreadAndCall<Unit>(getMainContext()) {
                ctx: JSContext => arkts_object["value"] = v.toJSValue(ctx)
            }
        }
    }

    /**
     * @brief getValue(): T
     */
    public func getValue(): T {
        jsObjApiCall<T>(arkts_object, "getValue", emptyArg) {
            ctx, info => T.fromJSValue(ctx, info)
        }
    }

    func toJSValue(context: JSContext): JSValue {
        arkts_object.toJSValue()
    }

    static func fromJSValue<T>(context: JSContext, input: JSValue): Box<T> {
        Box(input.asObject())
    }
}
