import std.collection.ArrayList

abstract class Animal {
    public func run(): String
}

class Dog <: Animal {
    public func run(): String {
        return "dog run"
    }
}

class Fox <: Animal {
    public func run(): String {
        return "fox run"
    }
}

class Zoo<T> where T <: Animal {
    var animals: ArrayList<Animal> = ArrayList<Animal>()
    public func addAnimal(a: T) {
        animals.add(a)
    }

    public func allAnimalRuns() {
        for (a in animals) {
            println(a.run())
        }
    }
}

main() {
    var zoo: Zoo<Animal> = Zoo<Animal>()
    zoo.addAnimal(Dog())
    zoo.addAnimal(Fox())
    zoo.allAnimalRuns()
}
