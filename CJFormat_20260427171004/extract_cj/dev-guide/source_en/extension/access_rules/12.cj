// package a
package a

private interface I0 {}

public class Foo<T> {}

// The extension is exported.
extend<T> Foo<T> <: I0 {}