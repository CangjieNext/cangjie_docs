interface Flyable {
    func fly(): Unit
}

class Bird <: Flyable {
    public func fly(): Unit {
        println("Bird flying")
    }
}

class Bat <: Flyable {
    public func fly(): Unit {
        println("Bat flying")
    }
}

class Airplane <: Flyable {
    public func fly(): Unit {
        println("Airplane flying")
    }
}

func fly(item: Flyable): Unit {
    item.fly()
}

main() {
    let bird = Bird()
    let bat = Bat()
    let airplane = Airplane()
    fly(bird)
    fly(bat)
    fly(airplane)
}
