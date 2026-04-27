struct A {
    public mut func f(): Unit {} // OK
    public mut operator func +(rhs: A): A { // OK
        A()
    }
    public mut static func g(): Unit {} // Error, static member functions cannot be modified with 'mut'
}