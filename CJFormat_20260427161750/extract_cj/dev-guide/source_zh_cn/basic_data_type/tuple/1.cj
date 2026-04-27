let tuple1 = (8, false)
var tuple2 = (true, 9, 20)
tuple2 = tuple1         // Error, mismatched types
tuple2[0] = false       // Error, 'tuple element' can not be assigned

var tuple3 = (9, true)
tuple3 = tuple1
println(tuple3[0])      // 8
println(tuple3[1])      // false