interface I1 {}
interface I2 <: I1 {}
interface I3 {}
interface I4 <: I3 {}

class A {}
extend A <: I1 & I4 {} // error: unable to decide which extension happens first
extend A <: I2 & I3 {} // error: unable to decide which extension happens first