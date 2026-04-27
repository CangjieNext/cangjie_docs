public class MathUtils {
    protected MathUtils(let arkts_object: JSObject) {}

    // Static property
    public mut prop PI: Float64 {
        get() {
            checkThreadAndCall<Float64>(getMainContext()) {
                ctx: JSContext => Float64.fromJSValue(ctx, getClassConstructorObj("test", "MathUtils")["PI"])
            }
        }
        set(v) {
            checkThreadAndCall<Unit>(getMainContext()) {
                ctx: JSContext => getClassConstructorObj("test", "MathUtils")["PI"] = v.toJSValue(ctx)
            }
        }
    }

    /**
     * @brief square(x: number): number
     */
    public static func square(x: Float64): Float64 {
        jsObjApiCall<Float64>(getClassConstructorObj("test", "MathUtils"), "square", {ctx => [x.toJSValue(ctx)]})
    }

    func toJSValue(context: JSContext): JSValue {
        arkts_object.toJSValue()
    }

    static func fromJSValue(context: JSContext, input: JSValue): MathUtils {
        MathUtils(input.asObject())
    }
}
