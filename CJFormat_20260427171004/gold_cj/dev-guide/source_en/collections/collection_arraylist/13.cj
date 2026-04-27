import std.collection.ArrayList

main() {
    let list = ArrayList<Int64>(100) // Allocate space at once
    for (i in 0..100) {
        list.add(i) // Does not trigger reallocation of space
    }
    list.reserve(100) // Prepare more space
    for (i in 0..100) {
        list.add(i) // Does not trigger reallocation of space
    }
}
