public class Foo {
    val a: Int64 = 9 // Error, expected declaration, found 'val'
    let b: String
    const init(b: String) {
        this.b = b
    }
}