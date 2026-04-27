main() {
    let tv = ("Alice", 24)
    let s = match (tv) {
        case ("Bob", age) => "Bob is ${age} years old"
        case ("Alice", age) => "Alice is ${age} years old"
        case (name, 100) => "${name} is 100 years old"
        case (x, x) => "someone" // Error, Cannot introduce a variable pattern with the same name, which will be a redefinition error.
    }
    println(s)
}
