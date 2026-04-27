public open class Shape {
    protected Shape(let arkts_object: JSObject) {}

    /**
     * @brief getArea(): number
     */
    public func getArea(): Float64 {
        jsObjApiCall<Float64>(arkts_object, "getArea", emptyArg)
    }

    func toJSValue(context: JSContext): JSValue {
        arkts_object.toJSValue()
    }

    static func fromJSValue(context: JSContext, input: JSValue): Shape {
        Shape(input.asObject())
    }
}
