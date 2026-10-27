# 模态类型概述

## 为什么需要 local 模式

仓颉的对象默认分配在 GC 堆上，由垃圾回收器在不确定的时间回收。函数内部经常会创建一些只在本函数里使用的临时对象，例如从文件或网络读入的字符串、解析得到的中间结构、计算用的临时数组。这些对象在函数返回后就不再需要，但在下一次垃圾回收之前仍然占用堆内存，在调用频繁或数据量大的场景下会推高程序的峰值内存。

local 模式用类型来描述“这个对象不会离开当前函数”。编译器据此检查对象确实没有逃逸，运行时则把这类对象分配在当前函数专属的一块内存区域（称为 local region）中：函数返回时整块 local region 一次性释放，不需要等待垃圾回收。

> **说明：**
>
> 本章所说的 local region 指为 local 对象划分的内存区域，与 GC 堆内部的 region 不是同一个概念。

## 模式与模态类型

在类型后面加上 `@` 和一个模式（mode），就得到模态类型（modal type）。与 local 相关的模式有三种：

| 写法 | 含义 |
|------|------|
| `T @~local` | 非 local。对象可以自由地被保存、返回、传递，与普通的仓颉对象完全相同 |
| `T @local!` | 一定是 local。对象的生命周期限定在当前函数（或调用者）的 local region 内，不能逃逸出去 |
| `T @local?` | 可能是 local。值可能是 local 的，也可能不是；使用时按 local 的要求加以限制 |

不写模式等价于写 `@~local`，因此已有代码中的类型含义不变。需要注意的是新增了 `exclave`、`demode` 两个关键字，已有代码中如果用它们作为标识符，需要改写为原始标识符，参见[关键字](../Appendix/keyword.md)。

`T @~local` 和 `T @local!` 都是 `T @local?` 的子类型：`@local?` 的变量或参数既可以接收 local 值，也可以接收非 local 值。`@~local` 与 `@local!` 之间没有子类型关系，不能互相赋值。

书写时需要注意：

- `@` 与模式之间可以有空格，但模式本身是一个整体，`~local`、`local!`、`local?` 内部不能有空格，`@local !`、`@~ local` 都是错误写法。本手册统一采用 `@local!` 这样不带空格的写法。
- `local` 不是关键字，只有出现在 `@` 之后时才表示模式，在其他位置仍然可以作为普通标识符使用。

## 可以标注模式的位置

模式可以写在以下常见位置：

- 局部变量和全局变量的类型（全局变量只能是 `@~local`）
- 函数的参数类型和返回类型
- 函数类型中的参数类型和返回类型，如 `(String @local?) -> Int64`
- 构造调用之后，用于指定构造出的实例的模式，如 `C() @local!`

以下位置不能标注模式：

- class、struct 的实例成员变量：成员的模式由所在实例决定，详见[成员与实例的模式](./local_mode_rules.md#成员与实例的模式)。
- 泛型实参，例如 `Array<String @local!>` 是错误写法；要表示“元素是 local 的数组”，应写作 `Array<String> @local!`。

## 第一个示例

下面的示例在 `sumOfSquares` 中创建一个临时数组，把它标注为 `@local!`，并交给只读的辅助函数 `total` 求和。`total` 的参数标注为 `@local?`，因此它既能接收 local 数组，也能接收普通数组。`getAllocatedLocalObjectSize()` 返回当前活跃的 local region 所占用的内存，用来观察 local 数组何时被回收：

<!-- verify -->

```cangjie
import std.runtime.getAllocatedLocalObjectSize

// 只读访问数组，local 数组和普通数组都可以传入
func total(xs: Array<Int64> @local?): Int64 {
    var sum = 0
    for (i in 0..xs.size) {
        sum += xs[i]
    }
    sum
}

func sumOfSquares(n: Int64): Int64 {
    // 临时数组只在本函数内使用，函数返回时随 local region 一起释放
    let squares = Array<Int64>(n, {i => i * i}) @local!
    println("in sumOfSquares, local memory in use: ${getAllocatedLocalObjectSize() > 0}")
    total(squares)
}

main() {
    let before = getAllocatedLocalObjectSize()
    let result = sumOfSquares(1000)
    let after = getAllocatedLocalObjectSize()
    println("result: ${result}")
    println("local memory released: ${after == before}")
    println(total([1, 2, 3]))
}
```

执行结果为：

```text
in sumOfSquares, local memory in use: true
result: 332833500
local memory released: true
6
```

local 对象不能离开创建它的函数。如果试图把上例中的 `squares` 作为返回值，编译器会报错：

<!-- compile.error -->

```cangjie
func squaresOf(n: Int64): Array<Int64> {
    let squares = Array<Int64>(n, {i => i * i}) @local!
    squares // Error, a @local! value cannot be returned as @~local
}
```

标准库中的常用类型（如 `Array`、`String`、`ArrayList`、`HashMap`）提供了接收或返回 local 值的重载版本，具体以各 API 文档的函数签名为准。

<!-- TODO(宋键): 原计划用 stdx `JsonValue.fromStr` 的 local 重载做端到端示例；流水线 stdx 产物尚无该重载，暂用 std 示例，待产物更新后补 JSON 示例。 -->

## 何时值得使用 local 模式

local 模式的收益体现在峰值内存，而不是吞吐量：它让临时对象在函数返回时立即释放，从而降低内存占用的峰值。适合的场景是函数内创建、函数内用完、体积较大或数量较多的临时对象。

是否值得改写，建议实际测量：

- 使用 `std.runtime` 包的 `getAllocatedLocalObjectSize()` 获取当前活跃 local region 占用的内存。它统计的是已向 local region 分配的内存块容量（包含内存块中尚未用完的部分），local 对象不计入 `getAllocatedHeapSize()` 的结果。
- 调用 `getAllocatedLocalObjectSize()` 时会暂停所有仓颉线程，不宜在性能敏感的路径上频繁调用。该函数的详细说明参见标准库 `std.runtime` 包的 API 文档。

单个 local region 的大小有上限，超出上限时会抛出 `LocalRegionOutOfMemoryError`。上限可以通过环境变量 `cjLocalRegionMaxSize` 配置，详见[运行时环境变量](../Appendix/runtime_env.md)。

<!-- TODO(宋键): 是否有可公开的收益数据或推荐场景？目前只写测量方法，不写数字。 -->

## 本章内容

- [local 模式的使用规则](./local_mode_rules.md)：赋值与逃逸、成员的模式、构造 local 实例、重载、闭包，以及使用约束。
- [exclave 表达式](./exclave.md)：如何修改 local 参数、如何把 local 对象返回给调用者。
- [Copyable 与 demode](./copyable_and_demode.md)：不受 local 限制的值类型，以及让成员变量不继承实例模式的方法。
