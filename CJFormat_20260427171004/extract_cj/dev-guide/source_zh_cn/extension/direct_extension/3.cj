class Foo<T> where T <: ToString {}

extend Foo<Int64> {} // OK

class Bar {}
extend Foo<Bar> {} // Error, generics type arguments do not match the constraint of 'Class-Foo<Generics-T>'