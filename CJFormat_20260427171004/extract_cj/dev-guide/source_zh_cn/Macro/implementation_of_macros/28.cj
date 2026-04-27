import define.*

@Outer
var a = 0

@Inner
var b = 0 // Error, The macro call 'Inner' should with the surround code contains a call 'Outer'.