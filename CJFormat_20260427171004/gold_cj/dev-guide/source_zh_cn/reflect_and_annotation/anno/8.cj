package test

import prod.*
import std.unittest.mock.*

@Test
public class TestA {
    @TestCase
    func case1(): Unit {
        {
            =>
                let matcher0 = Matchers.eq("z")
                let matcher1 = Matchers.eq("y")
                let stubCall = @EnsurePreparedToMock {=> return (test(matcher0.value(), matcher1.value()))}
                ConfigureMock.stubFunction(stubCall,
                    [matcher0.withDescription(#"eq("z")"#), matcher1.withDescription(#"eq("y")"#)], Option<String>.None,
                    "test", #"test("z", "y")"#, 15)
        }().returns("mocked value")
        println(test("z", "y")) // prints "mocked value"
    }
}
