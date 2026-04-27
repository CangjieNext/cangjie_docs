interface I {}
open class Base <: I {}
class Derived <: Base {}

func typePat(x: I) {
    match (x) {
        case a: Derived => "Derived"
        case b: Base => "Base"
        case _ => "Other"
    }
}