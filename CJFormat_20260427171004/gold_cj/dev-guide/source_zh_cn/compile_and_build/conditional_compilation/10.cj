@When[test]
@Test
class Tests {
    @TestCase
    public func case1(): Unit {
        @Expect("run", foo())
    }
}

func foo() {
    "run"
}

@When[!test]
main() {
    println(foo())
}
