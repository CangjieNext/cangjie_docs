// Catch with wildcardPattern.
try {
    throw OverflowException()
} catch (_) {
    println("catch an exception!")
}