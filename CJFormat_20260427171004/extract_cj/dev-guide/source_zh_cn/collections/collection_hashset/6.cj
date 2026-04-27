import std.collection.*

main() {
    let mySet = HashSet<Int64>([0, 1, 2])
    if (mySet.size == 0) {
        println("This is an empty hashset")
    } else {
        println("The size of hashset is ${mySet.size}")
    }
}