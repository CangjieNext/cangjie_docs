/*main_test.cj*/
package my_pkg

@Test
class Tests {
    @TestCase
    public func case1(): Unit {
        @Expect("ac", concatM("a", "c"))
    }
}