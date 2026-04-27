import std.collection.ArrayList

main() {
    let list = ArrayList<Int64>([0, 1, 2])
    if (list.size == 0) {
        println("This is an empty arraylist")
    } else {
        println("The size of arraylist is ${list.size}")
    }
}
