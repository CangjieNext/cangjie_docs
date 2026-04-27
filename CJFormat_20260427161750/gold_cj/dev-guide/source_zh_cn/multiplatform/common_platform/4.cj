// common file
package cjmp
​
common func foo1()   // error: 'common' function return type must be specified
common func foo2(): Unit   // ok
common func foo3(a!: Int64): Unit   // ok
common func foo4(a!: Int64 = 1): Unit   // ok
common func foo5(a: Int64): Unit { println("hello world") }   // ok

common func printValue1<T>(value: T): Unit where T <: ToString
common func printValue2<T>(value: T): Unit where T <: ToString