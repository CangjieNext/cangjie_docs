main() {
    let x = 0
    match (x) {
        case 1 =>
            let r1 = "x = 1"
            print(r1)
        case 0 =>
            let r2 = "x = 0" // Matched.
            print(r2)
        case _ =>
            let r3 = "x != 1 and x != 0"
            print(r3)
    }
}
