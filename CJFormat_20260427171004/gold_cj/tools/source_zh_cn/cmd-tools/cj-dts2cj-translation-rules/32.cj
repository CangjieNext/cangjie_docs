public class TestListener {
    protected TestListener(public var onStart!: Option<() -> Unit> = None,
        public var onDestroy!: Option<() -> Unit> = None,
        public var onError!: Option<(code: ErrorCode, msg: String) -> Unit> = None,
        public var onTouch!: Option<() -> Unit> = None, public var onEvent!: Option<(e: EventType) -> Unit> = None) {}

    public func toJSValue(context: JSContext): JSValue {
        let obj = context.object()
        if (let Some(v) <- onStart) {
            obj["onStart"] = context.function(
                {
                    ctx, _ =>
                        v()
                        ctx.undefined().toJSValue()
                }
            ).toJSValue()
        }
        if (let Some(v) <- onDestroy) {
            obj["onDestroy"] = context.function(
                {
                    ctx, _ =>
                        v()
                        ctx.undefined().toJSValue()
                }
            ).toJSValue()
        }
        if (let Some(v) <- onError) {
            obj["onError"] = context.function(
                {
                    ctx, info =>
                        let p0 = ErrorCode.fromJSValue(ctx, info[0])
                        let p1 = String.fromJSValue(ctx, info[1])
                        v(p0, p1)
                        ctx.undefined().toJSValue()
                }
            ).toJSValue()
        }
        if (let Some(v) <- onTouch) {
            obj["onTouch"] = context.function(
                {
                    ctx, _ =>
                        v()
                        ctx.undefined().toJSValue()
                }
            ).toJSValue()
        }
        if (let Some(v) <- onEvent) {
            obj["onEvent"] = context.function(
                {
                    ctx, info =>
                        let p0 = EventType.parse(Int32.fromJSValue(ctx, info[0]))
                        v(p0)
                        ctx.undefined().toJSValue()
                }
            ).toJSValue()
        }
        obj.toJSValue()
    }

    public static func fromJSValue(context: JSContext, input: JSValue): TestListener {
        let obj = input.asObject()
        TestListener(
            onStart: if (obj["onStart"].isUndefined()) {
                None
            } else {
                {
                    => checkThreadAndCall<Unit>(context, {
                        _ => obj["onStart"].asFunction().call()
                    })
                }
            },
            onDestroy: if (obj["onDestroy"].isUndefined()) {
                None
            } else {
                {
                    => checkThreadAndCall<Unit>(context, {
                        _ => obj["onDestroy"].asFunction().call()
                    })
                }
            },
            onError: if (obj["onError"].isUndefined()) {
                None
            } else {
                {
                    code: ErrorCode, msg: String => checkThreadAndCall<Unit>(
                        context,
                        {
                            ctx =>
                                let arg0 = code.toJSValue(ctx)
                                let arg1 = msg.toJSValue(ctx)
                                obj["onError"].asFunction().call([arg0, arg1])
                        }
                    )
                }
            },
            onTouch: if (obj["onTouch"].isUndefined()) {
                None
            } else {
                {
                    => checkThreadAndCall<Unit>(context, {
                        _ => obj["onTouch"].asFunction().call()
                    })
                }
            },
            onEvent: if (obj["onEvent"].isUndefined()) {
                None
            } else {
                {
                    e: EventType => checkThreadAndCall<Unit>(
                        context,
                        {
                            ctx =>
                                let arg0 = e.get().toJSValue(ctx)
                                obj["onEvent"].asFunction().call([arg0])
                        }
                    )
                }
            }
        )
    }
}
