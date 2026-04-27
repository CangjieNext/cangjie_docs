public class Person {
    // No need to generate private member properties
    protected Person(let arkts_object: JSObject) {}

    func toJSValue(context: JSContext): JSValue {
        arkts_object.toJSValue()
    }

    static func fromJSValue(context: JSContext, input: JSValue): Person {
        Person(input.asObject())
    }
}
