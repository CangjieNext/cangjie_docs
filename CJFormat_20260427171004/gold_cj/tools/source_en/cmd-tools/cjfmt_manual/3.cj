enum TimeUnit { // Correct: Opening brace on same line with 1 preceding space
    Year | Month | Day | Hour
} // Correct: Closing brace on own line

class A { // Correct: Opening brace on same line
    var count = 1
}

func fn(a: Int64): Unit { // Correct: Opening brace on same line
    if (a > 0) { // Correct: Opening brace on same line
    // CODE
    } else { // Correct: Closing brace and 'else' on same line
        // CODE
    } // Correct: Closing brace on own line
}

// Lambda functions
let add = {
    base: Int64, bonus: Int64 => // Correct: Lambda follows K&R style
        print("Correct news")
        base + bonus
}
