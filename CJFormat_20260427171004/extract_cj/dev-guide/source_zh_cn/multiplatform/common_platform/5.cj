// specific file
package cjmp
​
specific func foo2(a: Int64): Unit {}   // error: different arguments
specific func foo2(): Int64 {}   // error: different return type
public specific func foo2(): Int64 {}   // error: different modifiers
specific func foo2(): Unit {}   // ok

specific func foo3(a!: Int64): Unit { println("hello world") }   // ok

specific func foo4(a!: Int64 = 1): Unit {}   // error: 'specific' function parameter can not have default value
specific func foo4(a!: Int64): Unit {}   // ok

// common func foo5 有完整实现，无需在 specific 中定义。

specific func printValue1<R>(value: R): Unit  where R <: ToString {
    println(value)
}
specific func printValue2<T>(value: T): Unit {}

