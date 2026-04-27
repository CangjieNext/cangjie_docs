package A

public interface I1 {}

sealed interface I2 {} // OK

public sealed interface I3 {} // Warning, redundant modifier, 'sealed' implies 'public'

sealed open interface I4 {} // Warning, redundant modifier, 'sealed' implies 'open'

class C1 <: I1 {}

public open class C2 <: I1 {}

sealed abstract class C3 <: I2 {}

extend Int64 <: I2 {}
