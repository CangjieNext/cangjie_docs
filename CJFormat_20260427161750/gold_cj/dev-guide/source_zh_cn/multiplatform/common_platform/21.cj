// m_platform.cj
import cmp.*

main() {
    runCommonA(A())
    runCommonA(A2())
    runCommonA2(A2())
    println("=")
    let i1: I = A()
    let i2: I = A2()
    let i3: I = B()
    let i4: I = C()
    runPlatformI(i1)
    runPlatformI(i2)
    runPlatformI(i3)
    runPlatformI(i4)
    println("=")
    runPlatformI(A())
    runPlatformI(A2())
    runPlatformA(A())
    runPlatformA(A2())
    runPlatformA2(A2())
}
