import std.process.*
import std.collection.*

main(): Int64 {
    var args = ArrayList<String>(Process.current.arguments)

    if (args.size < 1) {
        eprintln("Error: failed to get parameters")
        return 1
    }

    println("Output: ${args[0]}")

    return 0
}