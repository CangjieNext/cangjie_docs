public class Person {
    // 不需要生成私有成员属性
    protected Person(let arkts_object: JSObject) {}

    func toJSValue(context: JSContext): JSValue {
        arkts_object.toJSValue()
    }

    static func fromJSValue(context: JSContext, input: JSValue): Person {
        Person(input.asObject())
    }
}
