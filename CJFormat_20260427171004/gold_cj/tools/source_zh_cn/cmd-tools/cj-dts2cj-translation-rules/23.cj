public class Drivable {
    protected Drivable(let arkts_object: JSObject) {}

    /**
     * @brief start(): void
     */
    public func start(): Unit {
        jsObjApiCall<Unit>(arkts_object, "start", emptyArg)
    }
    /**
     * @brief stop(): void
     */
    public func stop(): Unit {
        jsObjApiCall<Unit>(arkts_object, "stop", emptyArg)
    }

    func toJSValue(context: JSContext): JSValue {
        arkts_object.toJSValue()
    }

    static func fromJSValue(context: JSContext, input: JSValue): Drivable {
        Drivable(input.asObject())
    }
}

public class Car1 <: Drivable {
    protected Car1(arkts_object: JSObject) {}

    /**
     * @brief start(): void
     */
    public func start(): Unit {
        jsObjApiCall<Unit>(arkts_object, "start", emptyArg)
    }
    /**
     * @brief stop(): void
     */
    public func stop(): Unit {
        jsObjApiCall<Unit>(arkts_object, "stop", emptyArg)
    }

    func toJSValue(context: JSContext): JSValue {
        arkts_object.toJSValue()
    }

    static func fromJSValue(context: JSContext, input: JSValue): Car1 {
        Car1(input.asObject())
    }
}
