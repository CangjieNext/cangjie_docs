public class MyListener {
    let callbackManager = CallbackManager < String, JSValue >()
    protected MyListener(let arkts_object: JSObject) {}

    /**
    * @brief on(key: string,param: boolean,cb: (r: Record<string, string>) => void): void
    */
    public func on(key: String, param: Bool, cb: Callback1Argument<Record>): Unit {
        let key = key.toString()
        if(callbackManager.findCallbackObject(key, cb).isSome()) {
            return
        }
        let jsCallback = checkThreadAndCall < JSValue >(getMainContext()) {
            __ctx => __ctx.function {
                __ctx: JSContext, info: JSCallInfo =>
                let arg0 = Record<stringstring>.fromJSValue(__ctx, info[0])
                cb.invoke(arg0)
                __ctx.undefined().toJSValue()
            }.toJSValue()
        }
        callbackManager.put(key,(cb, jsCallback))
        jsObjApiCall < Unit >( arkts_object, "on", { __ctx =>[key.toJSValue(__ctx), param.toJSValue(__ctx), jsCallback] })
    }

    func toJSValue(context: JSContext): JSValue {
        arkts_object.toJSValue()
    }

    static func fromJSValue (context: JSContext, input: JSValue): MyListener {
        MyListener(input.asObject())
    }
}