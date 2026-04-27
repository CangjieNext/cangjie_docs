func translate(n: Byte) {
    match (n) {
        case "1" => 1
        case "2" => 2
        case "3" => 3
        case _ => -1
    }
}

main() {
    println(translate(51)) // UInt32(r'3') == 51
}