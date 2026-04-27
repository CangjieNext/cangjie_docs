// specific file
package cmp

specific struct Point<T> where T <: Add {
    specific var x: T
    specific var y: T
    specific init(x: T, y: T) {
        this.x = x
        this.y = y
    }
}
