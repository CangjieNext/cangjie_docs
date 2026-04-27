package pkg

import std.reflect.TypeInfo

@Annotation
public class Version {
    let code: String
    const init(code: String) {
        this.code = code
    }
}

@Version["1.0"]
class A {}

@Version["1.1"]
class B {}

main() {
    let objects = [A(), B()]
    for (obj in objects) {
        let annOpt = TypeInfo.of(obj).findAnnotation<Version>()
        if (let Some(ann) <- annOpt) {
            println(ann.code)
        }
    }
}