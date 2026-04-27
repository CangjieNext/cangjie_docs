public class IntersectionTypes<U, T> {

    protected IntersectionTypes(public var intersectionType: JSValue/* FIXME: `object & HashMap<U, T>` */) {}


    public func toJSValue(context: JSContext): JSValue {
        let obj = context.object()
        obj["intersectionType"] = intersectionType
        obj.toJSValue()
    }

    public static func fromJSValue <U, T>(context: JSContext, input: JSValue): IntersectionTypes<U, T> {
        let obj = input.asObject()
        IntersectionTypes(
        JSValue/* FIXME: `object & HashMap<U, T>` */.fromJSValue(context, obj["intersectionType"])
        )
    }

}