// file define.cj
macro package define         // 编译 define.cjo 携带 macro 属性
import std.ast.*

public func A() {}          // Error, 宏包不允许定义外部可见的非宏定义，此处会报错

public macro M(input: Tokens): Tokens { // macro M 外部可见
    return input
}