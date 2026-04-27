let a: (name: String, Int64) = ("banana", 5) // Error, in a parameter type list, either all parameters must be named, or none of them
let b: (name: String, price: Int64) = ("banana", 5) // OK
b.name // Error, undeclared identifier 'name'