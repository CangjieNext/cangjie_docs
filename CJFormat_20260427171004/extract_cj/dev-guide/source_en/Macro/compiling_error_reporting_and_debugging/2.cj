// src/demo.cj
import define.*
@Outer
class Demo {
    @Inner var state = 1
    @Inner var cnt = 42
}

main() {
    println("test macro")
}