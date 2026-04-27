interface Foo {
    func printValue(a: Int64): Unit
}

class Boo {
    var boo: Int64 = 2
}

extend Boo {
    public prop x: Int64 { // Adding a member property
        get() {
            123
        }
    }

    func newMember(): Unit {
        println("This is a member function of a new extension.") // Adding a member function
    }

    public operator func -() {
        println("Overload the operator addition function.") // Adding an operator overload function
        -x
    }
}

// Interface extension, implementing an interface
extend<T> Array<T> <: Foo {
    public func printValue(a: Int64) {
        println("The is ${a}.")
    }
}