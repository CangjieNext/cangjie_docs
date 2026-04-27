class MyList<T> {
    public let data: Array<T> = Array<T>()
}

extend<T> MyList<T> {} // OK

extend<R> MyList<R> {} // OK

extend<T, R> MyList<(T, R)> {} // OK

extend MyList {} // Error, generic type should be used with type argument

extend<T, R> MyList<T> {} // Error, type parameter 'R' must be used in extended type

extend<T, R> MyList<T, R> {} // Error, type argument's number does not match type parameter's number
