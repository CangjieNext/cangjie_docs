/*main.cj*/
package my_pkg

func concatM(s1: String, s2: String): String {
    return s1 + s2
}

main(): Int64 {
    println(concatM("a", "b"))
    0
}
