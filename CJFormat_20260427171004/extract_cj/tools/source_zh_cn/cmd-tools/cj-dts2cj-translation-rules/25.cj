public class Calculator {

    protected Calculator(let arkts_object: JSObject) {}


    /**
    * @brief add(x: number,y: number): number
    */
    public func add(x: Float64, y: Float64): Float64 {
        jsObjApiCall < Float64 >( arkts_object, "add", { ctx =>[x.toJSValue(ctx), y.toJSValue(ctx)] })
    }
    /**
    * @brief add(x: string,y: string): String
    */
    public func add(x: String, y: String): String {
        jsObjApiCall < String >( arkts_object, "add", { ctx =>[x.toJSValue(ctx), y.toJSValue(ctx)] })
    }
    /**
    * @brief add(x: any,y: any): any
    */
    public func add(x: Any, y: Any): any {
        jsObjApiCall < any >( arkts_object, "add", { ctx =>[x.toJSValue(ctx), y.toJSValue(ctx)] }) {
            ctx, info => any.fromJSValue(ctx, info)
        }
    }

    func toJSValue(context: JSContext): JSValue {
        arkts_object.toJSValue()
    }

    static func fromJSValue (context: JSContext, input: JSValue): Calculator {
        Calculator(input.asObject())
    }
}