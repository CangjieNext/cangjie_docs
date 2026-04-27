macro package define

import std.ast.*
import std.collection.HashMap

var Counts = HashMap<String, Int64>()

public macro Inner(input: Tokens) {
    for (t in input) {
        if (t.value.size == 0) {
            continue
        }
        // Count occurrences of all valid token values
        if (!Counts.contains(t.value)) {
            Counts[t.value] = 0
        }
        Counts[t.value] = Counts[t.value] + 1
    }
    return input
}

public macro B(input: Tokens) {
    return input
}
