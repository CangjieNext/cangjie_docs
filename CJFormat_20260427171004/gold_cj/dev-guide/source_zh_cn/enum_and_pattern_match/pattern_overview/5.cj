main() {
    let opt = Some(0)
    match (opt) {
        case x | x => {} // Error, variable cannot be introduced in patterns connected by '|'
        case Some(x) | Some(x) => {} // Error, variable cannot be introduced in patterns connected by '|'
        case x: Int64 | x: String => {} // Error, variable cannot be introduced in patterns connected by '|'
    }
}