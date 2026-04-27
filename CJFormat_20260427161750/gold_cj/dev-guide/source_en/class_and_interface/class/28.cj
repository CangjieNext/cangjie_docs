package A

public sealed abstract class C1 {} // Warning, redundant modifier, 'sealed' implies 'public'

sealed open abstract class C2 {} // Warning, redundant modifier, 'sealed' implies 'open'

sealed abstract class C3 {} // OK, 'public' is optional when 'sealed' is used

class S1 <: C1 {} // OK

public open class S2 <: C1 {} // OK

public sealed abstract class S3 <: C1 {} // OK

open class S4 <: C1 {} // OK
