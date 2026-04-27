public open class A {
    protected A(public var p: Float64) {}

    public open func toJSValue(context: JSContext): JSValue {
        let obj = context.object()
        obj["p"] = p.toJSValue(context)
        obj.toJSValue()
    }

    public static func fromJSValue(context: JSContext, input: JSValue): A {
        let obj = input.asObject()
        A(Float64.fromJSValue(context, obj["p"]))
    }
}

/* interface B {
    p1: number;
    }*/
public open class B <: A {
    protected B(p: Float64, public var p1: Float64) {
        super(p)
    }

    public open func toJSValue(context: JSContext): JSValue {
        let obj = context.object()
        obj["p"] = p.toJSValue(context)
        obj["p1"] = p1.toJSValue(context)
        obj.toJSValue()
    }

    public static func fromJSValue(context: JSContext, input: JSValue): B {
        let obj = input.asObject()
        B(
            Float64.fromJSValue(context, obj["p"]),
            Float64.fromJSValue(context, obj["p1"])
        )
    }
}

/* interface C {
    f(): void
    }*/
public open class C {
    protected C(public var arkts_object: JSObject) {}

    /**
     * @brief f(): void
     */
    public func f(): Unit {
        jsObjApiCall<Unit>(arkts_object, "f", emptyArg)
    }

    public open func toJSValue(context: JSContext): JSValue {
        arkts_object.toJSValue()
    }

    static func fromJSValue(context: JSContext, input: JSValue): C {
        C(input.asObject())
    }
}

/* interface D {
    }*/
public open class D <: C {
    protected D(arkts_object: JSObject) {
        super(arkts_object)
    }

    public open func toJSValue(context: JSContext): JSValue {
        arkts_object.toJSValue()
    }

    static func fromJSValue(context: JSContext, input: JSValue): D {
        D(input.asObject())
    }
}

/* interface E {
    }*/
public open class E <: A {
    protected E(p: Float64) {
        super(p)
    }

    public open func toJSValue(context: JSContext): JSValue {
        let obj = context.object()
        obj["p"] = p.toJSValue(context)
        obj.toJSValue()
    }

    public static func fromJSValue(context: JSContext, input: JSValue): E {
        let obj = input.asObject()
        E(Float64.fromJSValue(context, obj["p"]))
    }
}

/* interface F {
    g(): void
    }*/
public open class F <: C {
    protected F(arkts_object: JSObject) {
        super(arkts_object)
    }

    /**
     * @brief g(): void
     */
    public func g(): Unit {
        jsObjApiCall<Unit>(arkts_object, "g", emptyArg)
    }

    public open func toJSValue(context: JSContext): JSValue {
        arkts_object.toJSValue()
    }

    static func fromJSValue(context: JSContext, input: JSValue): F {
        F(input.asObject())
    }
}
