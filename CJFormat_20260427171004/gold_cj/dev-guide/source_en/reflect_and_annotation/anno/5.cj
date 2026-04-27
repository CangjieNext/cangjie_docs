// The result is truncated
@OverflowWrapping
func operation(a: Int32, b: Int32): Int32 {
    a + b // No exception will be thrown when overflow occurs
}
