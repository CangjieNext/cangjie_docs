func calc(a: Int32){
    println(a)
    return a * a
}
main() {
    let a: String
    if(calc(32) == 0){
      a = "1"
    }
    a = "2" // Error, cannot assign to immutable value
}