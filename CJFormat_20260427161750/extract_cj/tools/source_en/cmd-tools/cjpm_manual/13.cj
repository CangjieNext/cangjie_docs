// cj_project/pro0/src/zoo/zoo_test.cj
package pro0.zoo

import std.unittest.* // test framework
import std.unittest.testmacro.* // macro definition

@Test
public class TestZ{
    @TestCase
    func sayhi(): Unit {
        @Assert(concatZ("1", "2"), "12")
        @Assert(concatZ("1", "3"), "13")
    }
}