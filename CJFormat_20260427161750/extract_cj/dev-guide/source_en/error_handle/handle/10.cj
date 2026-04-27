open class Father <: Exception {
    var father: Int32 = 0
}
class ChildOne <: Father {
    var childOne: Int32 = 1
}

class ChildTwo <: Father {
    var childTwo: Int32 = 2
}

main() {
    try {
        throw ChildOne()
    } catch (e: ChildTwo | ChildOne) {
        println("${e is Father}")
    }
}