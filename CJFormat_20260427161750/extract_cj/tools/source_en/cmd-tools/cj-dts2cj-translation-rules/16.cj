public class Greeter {

    protected Greeter(let arkts_object: JSObject) {}
    /**
    * @brief constructor(greeting: string): void
    */
    public init(greeting: String) {
        arkts_object = checkThreadAndCall < JSObject >(getMainContext()) {
            __ctx =>
            let clazz = __ctx.global["Greeter"].asClass(__ctx)
            clazz.new(greeting.toJSValue(__ctx)).asObject()
        }
    }

    public mut prop greeting: String {
        get() {
            checkThreadAndCall < String >(getMainContext()) {
                ctx: JSContext => String.fromJSValue(ctx, arkts_object["greeting"])
            }
        }
        set(v) {
            checkThreadAndCall < Unit >(getMainContext()) {
                ctx: JSContext => arkts_object["greeting"] = v.toJSValue(ctx)
            }
        }

    }

    /**
    * @brief showGreeting(): void
    */
    public func showGreeting(): Unit {
        jsObjApiCall < Unit >( arkts_object, "showGreeting", emptyArg)
    }

    func toJSValue(context: JSContext): JSValue {
        arkts_object.toJSValue()
    }

    static func fromJSValue (context: JSContext, input: JSValue): Greeter {
        Greeter(input.asObject())
    }
}

