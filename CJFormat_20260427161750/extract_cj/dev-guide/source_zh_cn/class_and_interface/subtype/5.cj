interface I1 {}
interface I2 <: I1 {}

class C <: I2 {}

extend Bool <: I2 {}