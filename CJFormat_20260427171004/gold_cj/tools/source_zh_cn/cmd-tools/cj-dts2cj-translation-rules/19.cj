public class AnimalProtect {
    protected AnimalProtect(let arkts_object: JSObject) {}

    // 受保护属性
    public mut prop name: String {
        get() {
            checkThreadAndCall<String>(getMainContext()) {
                ctx: JSContext => String.fromJSValue(ctx, arkts_object["name"])
            }
        }
        set(v) {
            checkThreadAndCall<Unit>(getMainContext()) {
                ctx: JSContext => arkts_object["name"] = v.toJSValue(ctx)
            }
        }
    }

    /**
     * @brief makeSound(): void
     */
    public func makeSound(): Unit {
        jsObjApiCall<Unit>(arkts_object, "makeSound", emptyArg)
    }

    func toJSValue(context: JSContext): JSValue {
        arkts_object.toJSValue()
    }

    static func fromJSValue(context: JSContext, input: JSValue): AnimalProtect {
        AnimalProtect(input.asObject())
    }
}
