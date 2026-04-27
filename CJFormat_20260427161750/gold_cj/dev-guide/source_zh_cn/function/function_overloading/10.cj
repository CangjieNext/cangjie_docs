open class Base {}

class Sub <: Base {}

func outer() {
    func g(a: Sub) {
        print("1")
    }

    func inner() {
        func g(a: Base) {
            print("2")
        }

        g(Sub()) // Output: 2
    }
}
