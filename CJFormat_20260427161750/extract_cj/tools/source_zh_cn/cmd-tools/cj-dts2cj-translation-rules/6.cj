public class Point {

    protected Point(public let x: Float64,
    public let y: Float64) {}


    public func toJSValue(context: JSContext): JSValue {
        let obj = context.object()
        obj["x"] = x.toJSValue(context)
        obj["y"] = y.toJSValue(context)
        obj.toJSValue()
    }

    public static func fromJSValue (context: JSContext, input: JSValue): Point {
        let obj = input.asObject()
        Point(
        Float64.fromJSValue(context, obj["x"]),
        Float64.fromJSValue(context, obj["y"])
        )
    }

}