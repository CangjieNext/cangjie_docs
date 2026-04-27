struct Copy {
    var data = 2012
}

main() {
    let c1 = Copy()
    let c2 = c1
    c2.data = 2023 // Error, cannot assign to immutable value
}
