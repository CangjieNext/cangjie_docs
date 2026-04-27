// cj_project/src/main_test.cj
package test

import std.unittest.* // testfame
import std.unittest.testmacro.* // macro_Defintion

@Test
public class TestM{
    @TestCase
    func sayhi(): Unit {
        @Assert(concatM("1", "2"), "12")
        @Assert(concatM("1", "3"), "13")
    }
}