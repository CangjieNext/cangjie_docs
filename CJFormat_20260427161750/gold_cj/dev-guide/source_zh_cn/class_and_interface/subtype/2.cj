interface I1 {}

interface I2 {}

interface I3 <: I1 & I2 {}

class C <: I1 {}

extend Int64 <: I2 {}
