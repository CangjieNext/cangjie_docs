package B
import A.*

class S1 <: I1 {}  // OK
class S2 <: I2 {}  // Error, I2 is sealed interface, cannot be inherited here.