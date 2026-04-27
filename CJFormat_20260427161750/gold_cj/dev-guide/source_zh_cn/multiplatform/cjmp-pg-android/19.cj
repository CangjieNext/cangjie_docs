package cjworld

import java.lang.*
import javaworld.*

@JavaImpl
public class Interop {
    public static func m(a: ?A, s: ?JString, i: Int32): ?B {
        /* 此处可以实现各种逻辑 */
        B() // 假设com.example.b.B拥有一个`public`无参构造方法
    }
}
