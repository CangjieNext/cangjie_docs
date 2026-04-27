import std.collection.ArrayList

class ToPair {
    public static func fromArray<T>(l: ArrayList<T>): (T, T) {
        return (l[0], l[1])
    }
}

main() {
    var res: ArrayList<Int64> = ArrayList([1,2,3,4])
    var a: (Int64, Int64) = ToPair.fromArray<Int64>(res)
}