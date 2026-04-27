import std.collection.ArrayList

main() {
    let list = ArrayList<Int64>()
    list.add(0) // list contains element 0
    list.add(1) // list contains elements 0, 1
    let li = [2, 3]
    list.add(all: li) // list contains elements 0, 1, 2, 3
}