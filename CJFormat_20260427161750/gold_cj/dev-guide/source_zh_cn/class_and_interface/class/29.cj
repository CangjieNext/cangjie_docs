package B

import A.*

class SS1 <: S2 {} // OK

class SS2 <: S3 {} // Error, S3 is sealed class, cannot be inherited here

sealed class SS3 {} // Error, 'sealed' cannot be used on non-abstract class
