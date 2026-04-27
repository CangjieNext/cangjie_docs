var isPresent: Bool = false  // Correct: Space after colon
func method(isEmpty!: Bool): RetType { ... } // Correct: Space after colon in params/return

method(isEmpty: isPresent) // Correct: Space after colon in named args

0..MAX_COUNT : -1 // Correct: No spaces around range operator, spaces around step colon

var hundred = 0
do { // Correct: Space between 'do' and brace
    hundred++
} while (hundred < 100) // Correct: Space between 'while' and paren

func fn(paramName1: ArgType, paramName2: ArgType): ReturnType { // Correct: No inner paren spaces
    ...
    for (i in 1..4) { // Correct: No spaces around range operator
        ...
    }
}

let listOne: Array<Int64> = [1, 2, 3, 4] // Correct: No inner bracket/paren spaces

let salary = base + bonus // Correct: Spaces around binary operators

x++ // Correct: No space for unary operators