main() {
    let score = 90
    let level = match (score) {
        case 0 | 10 | 20 | 30 | 40 | 50 => "D"
        case 60 => "C"
        case 70 | 80 => "B"
        case 90 | 100 => "A" // Matched.
        case _ => "Not a valid score"
    }
    println(level)
}
