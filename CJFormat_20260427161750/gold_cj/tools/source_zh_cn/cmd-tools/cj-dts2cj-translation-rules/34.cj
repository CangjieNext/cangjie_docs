public class Optionals {
    protected Optionals(public var optionalParam10: (a: Float64, b: ?String) -> Unit,
        public var optionalField1!: Option<Float64> = None) {}

    public func toJSValue(context: JSContext): JSValue {
        let obj = context.object()
        obj["optionalParam10"] = context.function(
            {
                ctx, info =>
                    let p0 = Float64.fromJSValue(ctx, info[0])
                    let p1 = String.fromJSValue(ctx, info[1])
                    optionalParam10(p0, p1)
                    ctx.undefined().toJSValue()
            }
        ).toJSValue()
        if (let Some(v) <- optionalField1) {
            obj["optionalField1"] = v.toJSValue(context)
        }
        obj.toJSValue()
    }

    public static func fromJSValue(context: JSContext, input: JSValue): Optionals {
        let obj = input.asObject()
        Optionals(
            {
                a: Float64, b: ?String => checkThreadAndCall<Unit>(
                    context,
                    {
                        ctx =>
                            let arg0 = a.toJSValue(ctx)
                            let arg1 = b?.toJSValue(ctx)
                            obj["optionalParam10"].asFunction().call([arg0, arg1])
                    }
                )
            },
            optionalField1: if (obj["optionalField1"].isUndefined()) {
                None
            } else {
                Float64.fromJSValue(context, obj["optionalField1"])
            }
        )
    }
}
