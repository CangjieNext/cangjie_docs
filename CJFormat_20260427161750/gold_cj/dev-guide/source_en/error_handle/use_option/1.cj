func getOrThrow(a: ?Int64) {
    match (a) {
        case Some(v) => v
        case None => throw NoneValueException()
    }
}
