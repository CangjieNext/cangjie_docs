package pkg

import std.reflect.TypeInfo

@Annotation
public class Marked {
    const init() {}
}

@Marked
open class A {}

class B <: A {}

main() {
    if (TypeInfo.of(A()).findAnnotation<Marked>().isSome()) {
        println("A is Marked")
    }
    if (TypeInfo.of(B()).findAnnotation<Marked>().isSome()) {
        println("B is Marked")
    }
}
