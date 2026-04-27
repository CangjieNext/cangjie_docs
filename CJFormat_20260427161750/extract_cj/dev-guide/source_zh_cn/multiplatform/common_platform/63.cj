// specific file
package cmp
public import std.sort.*

public specific func foo() { println("specific func foo") }

public func goo(){
    println("specific func goo")
    sort([1, 4, 3])
}