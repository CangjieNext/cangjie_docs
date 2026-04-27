// cj_project/src/koo/koo_test.cj
package test.koo

import std.unittest.* // testfame
import std.unittest.testmacro.* // macro_Defintion

@Test
public class TestK {
    @TestCase
    func sayhi(): Unit {
        @Assert(concatk("1", "2"), "12")
        @Assert(concatk("1", "3"), "13")
    }
}
