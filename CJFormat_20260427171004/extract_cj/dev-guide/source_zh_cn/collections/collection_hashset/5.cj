import std.collection.*

main() {
    let mySet = HashSet<Int64>([0, 1, 2])
    for (i in mySet) {
        println("The element is ${i}")
    }
}