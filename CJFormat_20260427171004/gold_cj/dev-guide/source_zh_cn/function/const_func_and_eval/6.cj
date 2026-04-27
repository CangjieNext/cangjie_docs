var a = "4123"

class Foo {
    let foo: String
    let boo: Int64
    const init() {
        foo = "aa" // OK
        boo += 10 // Error, variable 'boo' is used before initialization
    }
}
