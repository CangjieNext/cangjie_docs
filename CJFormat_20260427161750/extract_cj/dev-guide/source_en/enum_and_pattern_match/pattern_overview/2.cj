func translate(n: Rune) {
    match (n) {
        case "A" => 1
        case "B" => 2
        case "C" => 3
        case _ => -1
    }
}

main() {
    println(translate(r"C"))
}