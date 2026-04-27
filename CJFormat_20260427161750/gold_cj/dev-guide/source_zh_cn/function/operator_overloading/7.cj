enum E {
    Y | X | X(Int64)

    public operator func ()(p: Int64) {}
    public operator func ()(p: Float64) {}
}

main() {
    let e = X(1) // OK, X(1) is to call the constructor X(Int64)
    X(1.0) // OK, X(1.0) is to call the operator () overloading function
    let e1 = X
    e1(1) // OK, e1(1) is to call the operator () overloading function
    Y(1) // OK, Y(1) is to call the operator () overloading function
}
