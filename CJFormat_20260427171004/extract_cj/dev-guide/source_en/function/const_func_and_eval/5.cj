var a = "4123"

class Foo {
    let foo: String = a // Error, expected 'const' expression guaranteed to be evaluated at compile time
    const init() {}
}