// 计算结果被高位截断
@OverflowWrapping
func operation(a: Int32, b: Int32): Int32 {
    a + b // No exception will be thrown when overflow occurs
}
