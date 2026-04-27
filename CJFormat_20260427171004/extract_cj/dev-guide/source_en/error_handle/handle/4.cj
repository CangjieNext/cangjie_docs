open class C {}

open class D <: C {}

class E <: D {}

main () {
    let x = try {
        E()
    } catch (e: Exception) {
        D()
    } finally {
        C()
    }
    0
}