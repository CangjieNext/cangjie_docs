main() {
    let a = Some(3)
    let c = if (let Some(b) <- a) {
        1 // Pattern match succeeds, c = 1
    } else {
        2
    }
    let d = Some(1)

    if (let Some(e) <- a && let Some(f) <- d) { // Both patterns match; condition evaluates to true
        println("${e} ${f}") // prints 3 1
    }

    if (let Some(f) <- d && f > 3) { // Pattern matches; f = 1, f > 3 check fails; jumps to else branch
        println("${f}")
    } else {
        println("d is None or value of d is less or equal to 3") // prints this line
    }

    if (let Some(_) <- a || let Some(_) <- d) { // Enum patterns connected by ||, no variable binding; correct
        println("at least one of a and d is Some") // prints this line
    } else {
        println("both a and d are None")
    }

    let g = 3
    if (let Some(_) <- a || g > 1) {
        println("this") // prints this line
    } else {
        println("that")
    }
}
