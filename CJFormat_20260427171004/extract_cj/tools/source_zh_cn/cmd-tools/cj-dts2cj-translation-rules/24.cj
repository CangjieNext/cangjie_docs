public class Animal1 {

    protected Animal1(let arkts_object: JSObject) {}
    /**
    * @brief constructor(name: string): void
    */
    public init(name: String) {
        arkts_object = checkThreadAndCall < JSObject >(getMainContext()) {
            __ctx =>
            let module = getJSModule(__ctx, "test", None)
            let clazz = module["Animal1"].asClass(__ctx)
            clazz.new(name.toJSValue(__ctx)).asObject()
        }
    }

    public mut prop name: String {
        get() {
            checkThreadAndCall < String >(getMainContext()) {
                ctx: JSContext => String.fromJSValue(ctx, arkts_object["name"])
            }
        }
        set(v) {
            checkThreadAndCall < Unit >(getMainContext()) {
                ctx: JSContext => arkts_object["name"] = v.toJSValue(ctx)
            }
        }

    }

    /**
    * @brief move(distance: number): void
    */
    public func move(distance: Float64): Unit {
        jsObjApiCall < Unit >( arkts_object, "move", { ctx =>[distance.toJSValue(ctx)] })
    }

    func toJSValue(context: JSContext): JSValue {
        arkts_object.toJSValue()
    }

    static func fromJSValue (context: JSContext, input: JSValue): Animal1 {
        Animal1(input.asObject())
    }
}
public class Dog <: Animal1 {

    protected Dog(arkts_object: JSObject) {}


    /**
    * @brief bark(): void
    */
    public func bark(): Unit {
        jsObjApiCall < Unit >( arkts_object, "bark", emptyArg)
    }

    func toJSValue(context: JSContext): JSValue {
        arkts_object.toJSValue()
    }

    static func fromJSValue (context: JSContext, input: JSValue): Dog {
        Dog(input.asObject())
    }
}