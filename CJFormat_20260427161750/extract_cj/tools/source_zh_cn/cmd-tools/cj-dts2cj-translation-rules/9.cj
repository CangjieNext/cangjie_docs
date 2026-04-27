public class List {

    protected List(let arkts_object: JSObject) {}


    public mut prop items: Array<String> {
        get() {
            checkThreadAndCall < Array<String> >(getMainContext()) {
                ctx: JSContext => Array<String>.fromJSValue(ctx, arkts_object["items"])
            }
        }
        set(v) {
            checkThreadAndCall < Unit >(getMainContext()) {
                ctx: JSContext => arkts_object["items"] = v.toJSValue(ctx)
            }
        }

    }

    /**
    * @brief add(item: string): void
    */
    public func add(item: String): Unit {
        jsObjApiCall < Unit >( arkts_object, "add", { ctx =>[item.toJSValue(ctx)] })
    }

    func toJSValue(context: JSContext): JSValue {
        arkts_object.toJSValue()
    }

    static func fromJSValue (context: JSContext, input: JSValue): List {
        List(input.asObject())
    }
}