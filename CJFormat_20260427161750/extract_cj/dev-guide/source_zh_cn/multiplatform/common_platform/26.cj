// common file
package cmp

interface Add {
    common operator func +(right: Add): Add
}

common struct Point<T> where T <: Add {
    common var x: T
    common var y: T
    common init(x: T, y: T) { this.x = x; this.y = y }
}