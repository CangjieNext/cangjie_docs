// specific file
pkg cjmp

specific func foo2(a: Int64): Unit {}   // error: different arguments
specific func foo2(): Int64 {}   // error: different return type
public specific func foo2(): Int64 {}   // error: different modifiers
specific func foo2(): Unit {}   // ok

specific func foo3(a!: Int64): Unit { println("hello word") }   // ok

specific func foo4(a!: Int64 = 1): Unit {}   error: 'specific' function parameter can not have default value
specific func foo4(a!: Int64): Unit {}   // ok

// common func foo5 has a complete implementation, so no platform definition is needed.