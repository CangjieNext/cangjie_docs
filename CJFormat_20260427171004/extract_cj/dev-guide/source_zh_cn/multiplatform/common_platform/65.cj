// specific file
import cmp.*

main() {
    foo() // 来自 specific 的 foo
    goo() // 仅在 specific 可见
    sort([1,4,3]) // 仅在 specific 可见，由于仅在 specific 做了 public import
}