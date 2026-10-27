# local 模式的使用规则

> **说明：**
>
> local 模式是实验特性。本节示例都按开启 local 模式编写，编译时需要加上 `--experimental --enable-local-mode` 编译选项，参见[开启 local 模式](./modal_overview.md#开启-local-模式)。

本节介绍编写 local 代码时需要遵守的规则。本节的规则都由编译器在编译期检查，违反时直接报错。运行时可能出现的问题（如 local region 超出上限）见[模态类型概述](./modal_overview.md#何时值得使用-local-模式)。

## 赋值、返回与逃逸

`@local!` 的值不能离开当前函数，因此：

- 不能赋值给 `@~local` 的变量；
- 不能保存到全局变量或静态成员变量中（它们只能是 `@~local`）；
- 不能作为 `@~local` 的返回值返回。

<!-- compile.error -->
<!-- cfg="--experimental --enable-local-mode" -->

```cangjie
var cache: String = ""

func process(): String {
    let s: String @local! = "temporary"
    let t: String = s // Error, @local! cannot be assigned to @~local
    cache = s // Error, @local! cannot be stored in a global variable
    return s // Error, @local! cannot be returned as @~local
}
```

`@local?` 的变量或参数可以接收 local 值和非 local 值，因此常用于只读取、不保存数据的函数参数：

<!-- verify -->
<!-- cfg="--experimental --enable-local-mode" -->

```cangjie
func describe(s: String @local?): String {
    if (s.isEmpty()) {
        "empty"
    } else {
        "size ${s.size}"
    }
}

main() {
    let a: String @local! = "local"
    let b: String = "not local"
    println(describe(a))
    println(describe(b))
}
```

执行结果为：

```text
size 5
size 9
```

由于 `@local?` 的值可能是 local 的，它同样不能逃逸：

<!-- compile.error -->
<!-- cfg="--experimental --enable-local-mode" -->

```cangjie
func keep(s: String @local?): String {
    return s // Error, @local? cannot be returned as @~local
}
```

上述限制只针对含有引用的类型。数值、`Bool`、`Rune` 等实现了 `Copyable` 接口的类型，赋值时复制的就是值本身，不会造成逃逸，因此不受 local 模式的限制，可以在各种模式之间自由转换（详见 [Copyable 与 demode](./copyable_and_demode.md)）：

<!-- verify -->
<!-- cfg="--experimental --enable-local-mode" -->

```cangjie
func count(): Int64 {
    let n: Int64 @local! = 42
    let m: Int64 = n // OK, Int64 is Copyable
    return n + m
}

main() {
    println(count())
}
```

执行结果为：

```text
84
```

## 成员与实例的模式

class 和 struct 的实例成员变量声明时不写模式，它的模式由所在实例决定：通过 `@local!` 的实例访问到的成员是 `@local!`，通过 `@local?` 的实例访问到的成员是 `@local?`。同理，`Array<T> @local!` 的元素也是 `@local!`。

元组的模式由各元素共同决定：如果元素中既有 `@local!` 的值又有 `@~local` 的值，元组的模式是 `@local?`。

不能给 `@local?` 实例的非 `Copyable` 成员赋值，也不能给 `@local?` 数组的非 `Copyable` 元素赋值。原因是 `@local?` 的实例实际上可能是非 local 的，如果允许赋值，就可能让一个非 local 对象引用 local 对象，而 local 对象会随 local region 释放。`Copyable` 类型的成员和元素不受此限制。

<!-- compile.error -->
<!-- cfg="--experimental --enable-local-mode" -->

```cangjie
class Order {
    var item: String
    var count: Int64
    init(item: String, count: Int64) {
        this.item = item
        this.count = count
    }
    exclave init(this @local!, item: String @local!, count: Int64) {
        this.item = item
        this.count = count
    }
}

var lastItem: String = ""

func record(o: Order @local!) {
    lastItem = o.item // Error, o.item has type String @local!
}

func update(o: Order @local?) {
    o.count = 2 // OK, Int64 is Copyable
    o.item = "pen" // Error, cannot assign to non-Copyable member of a @local? instance
}

func fill(names: Array<String> @local?, counts: Array<Int64> @local?) {
    counts[0] = 0 // OK, Int64 is Copyable
    names[0] = "none" // Error, cannot assign to non-Copyable element of a @local? array
}
```

上例中的 `exclave init(this @local!, ...)` 用于构造 local 实例，见下一小节。

## 构造 local 实例

实例的模式由构造函数决定。在 `init` 的参数列表开头写上 `this @local!` 或 `this @local?`，该构造函数构造出的就是相应模式的实例；不写时等价于 `this @~local`。主构造函数总是构造 `@~local` 的实例。

`this @local!` 和 `this @local?` 的构造函数，整个函数体必须是一个 exclave 表达式，通常直接用 `exclave` 修饰 `init` 来表达（参见 [exclave 表达式](./exclave.md)）。在这样的构造函数中可以给成员赋值，不受上一小节“不能给 `@local?` 实例的成员赋值”的限制。

构造实例时，在构造调用之后写上模式来选择构造函数，例如 `Order("pen", 2) @local!`；也可以通过变量的类型来选择：

<!-- verify -->
<!-- cfg="--experimental --enable-local-mode" -->

```cangjie
class Order {
    var item: String
    var count: Int64
    init(item: String, count: Int64) {
        this.item = item
        this.count = count
    }
    exclave init(this @local!, item: String @local!, count: Int64) {
        this.item = item
        this.count = count
    }
}

main() {
    let a = Order("book", 1) // @~local instance
    let b = Order("pen", 2) @local! // @local! instance
    let c: Order @local! = Order("ink", 3) // constructor selected by the variable type
    println("${a.item} ${b.item} ${c.item}")
}
```

执行结果为：

```text
book pen ink
```

如果类型没有对应模式的构造函数，就不能构造该模式的实例。例如下面的 `Point` 只有默认模式的构造函数：

<!-- compile.error -->
<!-- cfg="--experimental --enable-local-mode" -->

```cangjie
class Point {
    var x: Int64
    init(x: Int64) {
        this.x = x
    }
}

main() {
    let p = Point(1) @local! // Error, no @local! constructor
}
```

`this @local!` 或 `this @local?` 的构造函数如果没有写成 exclave，编译器会报错：

<!-- compile.error -->
<!-- cfg="--experimental --enable-local-mode" -->

```cangjie
class Label {
    var text: String
    init(text: String) {
        this.text = text
    }
    init(this @local!, text: String @local!) { // Error, body must be an exclave
        this.text = text
    }
}
```

在构造函数中通过 `this(...)` 调用另一个构造函数时，被调用的构造函数必须与当前构造函数的 `this` 模式相同。

## 成员函数的 this 模式

实例成员函数中 `this` 的模式也需要确定。在参数列表开头写 `this @模式` 来指定，例如 `func show(this @local?): String`；不写时等价于 `this @~local`。`this @...` 只是对 `this` 的说明，不是参数，调用时不需要也不能为它传值。

通过实例调用成员函数时，实例的模式必须是 `this` 模式的子类型：

| 实例的模式 | 可以调用的成员函数 |
|-----------|------------------|
| `@~local` | `this @~local`（即不写）、`this @local?` |
| `@local!` | `this @local!`、`this @local?` |
| `@local?` | `this @local?` |

因此，如果希望某个只读的成员函数对任何模式的实例都可用，应把它声明为 `this @local?`。

<!-- compile.error -->
<!-- cfg="--experimental --enable-local-mode" -->

```cangjie
class Counter {
    var n: Int64 = 0
    init() {}
    exclave init(this @local!) {}
    func value(): Int64 {
        n
    }
    func reset(this @local!): Unit {
        n = 0
    }
}

func use(c: Counter @local?) {
    let a = Counter() @local!
    a.value() // Error, a @local! instance cannot call a this @~local member function
    c.value() // Error, a @local? instance cannot call a this @~local member function
    Counter().reset() // Error, a @~local instance cannot call a this @local! member function
}
```

同一个成员函数可以只按 `this` 模式重载。调用时选择 `this` 模式与实例模式最匹配的版本：

<!-- verify -->
<!-- cfg="--experimental --enable-local-mode" -->

```cangjie
class C {
    init() {}
    exclave init(this @local!) {}
    func name(this @~local): String {
        "this @~local"
    }
    func name(this @local?): String {
        "this @local?"
    }
    func name(this @local!): String {
        "this @local!"
    }
}

func test(p: C @local?) {
    let a = C()
    let b = C() @local!
    println(a.name())
    println(b.name())
    println(p.name())
}

main() {
    test(C())
}
```

执行结果为：

```text
this @~local
this @local!
this @local?
```

实现接口函数或覆盖父类函数时，`this` 模式必须与被实现或被覆盖的函数完全相同：

<!-- verify -->
<!-- cfg="--experimental --enable-local-mode" -->

```cangjie
interface Shape {
    func area(this @local?): Int64
}

class Square <: Shape {
    let side: Int64
    init(side: Int64) {
        this.side = side
    }
    public func area(this @local?): Int64 { // same this mode as Shape.area
        side * side
    }
}

func areaOf(s: Shape @local?): Int64 {
    s.area()
}

main() {
    println(areaOf(Square(3)))
}
```

执行结果为：

```text
9
```

<!-- compile.error -->
<!-- cfg="--experimental --enable-local-mode" -->

```cangjie
interface Shape {
    func area(this @local?): Int64
}

class Square <: Shape { // Error, area(this @local?) is not implemented
    public func area(): Int64 {
        1
    }
}

open class Base {
    public open func id(this @local?): Int64 {
        1
    }
}

class Derived <: Base {
    public override func id(): Int64 { // Error, this mode differs from the overridden function
        2
    }
}
```

## 按参数模式重载

函数可以只按参数的模式重载。标准库中常见的做法是同时提供 `f(x: T)` 和 `f(x: T @local?)` 两个版本。调用时，编译器选择参数模式与实参模式最匹配的版本：

<!-- verify -->
<!-- cfg="--experimental --enable-local-mode" -->

```cangjie
func f(_: String): String {
    "f(String)"
}

func f(_: String @local?): String {
    "f(String @local?)"
}

func g(_: String @local!): String {
    "g(String @local!)"
}

func g(_: String @local?): String {
    "g(String @local?)"
}

func test(p: String @local?) {
    let a: String = "a"
    let b: String @local! = "b"
    println(f(a))
    println(f(b))
    println(f(p))
    println(g(a))
    println(g(b))
    println(g(p))
}

main() {
    test("p")
}
```

执行结果为：

```text
f(String)
f(String @local?)
f(String @local?)
g(String @local?)
g(String @local!)
g(String @local?)
```

即：实参为 `@~local` 时优先选 `@~local` 版本，没有时选 `@local?` 版本；实参为 `@local!` 时优先选 `@local!` 版本，没有时选 `@local?` 版本；实参为 `@local?` 时只能选 `@local?` 版本。

如果没有任何版本能接收实参的模式，调用会报错。例如只提供 `@local!` 版本时，不能传入 `@~local` 或 `@local?` 的实参：

<!-- compile.error -->
<!-- cfg="--experimental --enable-local-mode" -->

```cangjie
func h(s: String @local!): Int64 {
    s.size
}

func test(p: String @local?) {
    let a: String = "a"
    h(a) // Error, no h accepts a @~local argument
    h(p) // Error, no h accepts a @local? argument
}
```

## 传递 @local! 参数

`@local!` 的值分为两类，编译器的报错信息中分别称为 external 和 internal：

- **外部 local!**（external）：函数的 `@local!` 参数，以及通过它访问到的成员。它们由调用者创建，属于调用者的 local region。
- **内部 local!**（internal）：在当前函数中创建的 `@local!` 值，属于当前函数的 local region，函数返回时就会释放。

外部 local! 比内部 local! 活得更久，因此二者不能混用：内部 local! 不能赋给外部 local! 的成员（需要时使用 [exclave](./exclave.md)），内部 local! 不能作为返回值返回，而外部 local! 可以作为 `@local!` 的返回值返回给调用者。

此外，在 exclave 之外，外部 local!（`Copyable` 类型除外）还有两条限制：

- 不能直接作为实参传给其他函数；
- 不能用来调用 `this @local!` 的成员函数。

<!-- compile.error -->
<!-- cfg="--experimental --enable-local-mode" -->

```cangjie
class Doc {
    var title: String
    init(title: String) {
        this.title = title
    }
    exclave init(this @local!, title: String @local!) {
        this.title = title
    }
    exclave func clear(this @local!): Unit {
        title = ""
    }
}

func size(s: String @local?): Int64 {
    s.size
}

func process(d: Doc @local!): Int64 {
    d.clear() // Error, cannot call a this @local! member function on a @local! parameter
    size(d.title) // Error, cannot pass a @local! parameter (or its member) as an argument
}
```

需要传递时，可以采用以下两种写法之一：

- 先把参数赋给一个 `@local?` 变量，再把该变量传给 `@local?` 形参；
- 在 [exclave](./exclave.md) 中传递或调用，此时外部 local! 视同内部 local!，可以传给 `@local!` 形参，也可以调用 `this @local!` 的成员函数。

通过外部 local! 调用 `this @local?` 的成员函数、访问 `Copyable` 类型的成员，不受上述限制。

<!-- verify -->
<!-- cfg="--experimental --enable-local-mode" -->

```cangjie
func size(s: String @local?): Int64 {
    s.size
}

func sizeL(s: String @local!): Int64 {
    s.size
}

func forward1(s: String @local!): Int64 {
    let t: String @local? = s
    size(t)
}

exclave func forward2(s: String @local!): Int64 {
    sizeL(s)
}

main() {
    let s: String @local! = "abc"
    println(forward1(s))
    println(forward2(s))
}
```

执行结果为：

```text
3
3
```

## 闭包与嵌套函数

lambda 表达式和嵌套函数会捕获外部变量，捕获规则如下：

- 不能捕获 `@local!` 的变量。
- 捕获了 `@local?` 变量的 lambda，其自身的模式是 `@local?`，因此不能逃逸，例如不能赋值给 `@~local` 的变量。
- 不能创建 `@local!` 的函数对象，即 lambda 的类型不能是 `@local!` 的函数类型。

<!-- compile.error -->
<!-- cfg="--experimental --enable-local-mode" -->

```cangjie
var onDone: () -> Int64 = {=> 0}

func run() {
    let text: String @local! = "abc"
    let view: String @local? = text
    let byText = {=> text.size} // Error, cannot capture a @local! variable
    let byView = {=> view.size}
    onDone = byView // Error, a @local? lambda cannot be assigned to @~local
    let fixed: (() -> Int64) @local! = {=> 1} // Error, a lambda cannot have a @local! function type
}
```

捕获 `@local?` 变量的 lambda 可以在当前函数内正常调用：

<!-- verify -->
<!-- cfg="--experimental --enable-local-mode" -->

```cangjie
func run() {
    let text: String @local! = "hello"
    let view: String @local? = text
    let length: (() -> Int64) @local? = {=> view.size}
    println(length())
}

main() {
    run()
}
```

执行结果为：

```text
5
```

嵌套函数默认是 `@~local` 的，不能捕获 `@local?` 和 `@local!` 的变量。要捕获 `@local?` 变量，在 `func` 前写上 `@local?`；嵌套函数同样不能捕获 `@local!` 变量：

<!-- verify -->
<!-- cfg="--experimental --enable-local-mode" -->

```cangjie
func run() {
    let text: String @local! = "hello"
    let view: String @local? = text
    @local? func length(): Int64 {
        view.size
    }
    println(length())
}

main() {
    run()
}
```

执行结果为：

```text
5
```

<!-- compile.error -->
<!-- cfg="--experimental --enable-local-mode" -->

```cangjie
func run() {
    let text: String @local! = "hello"
    let view: String @local? = text
    func length1(): Int64 {
        view.size // Error, a @~local nested function cannot capture a @local? variable
    }
    @local? func length2(): Int64 {
        text.size // Error, cannot capture a @local! variable
    }
}
```

<!-- TODO(宋键): 嵌套函数模式说明符按实现写为前置 `@local? func name()`，请确认这是最终语法。 -->

## 约束

以下场景对 local 值有额外限制：

- **spawn**：spawn 块中不能使用块外声明的、非 `Copyable` 类型的 `@local!` 或 `@local?` 变量，块的结果只能是 `@~local` 的值。spawn 块中可以创建自己的 local 对象，它们在块执行结束时释放。spawn 块中不能使用 exclave 表达式。
- **异常**：`throw` 的操作数只能是 `@~local` 的值；catch 中绑定的异常变量是 `@~local` 的，可以自由保存。
- **泛型**：泛型实参不能带模式（如 `Array<String @local!>`）。泛型函数的形参 `x: T` 是 `@~local` 的，如果要接收 local 值，需要写成 `x: T @local?` 等形式。
- **C 语言互操作**：`@C` 修饰的函数和 `foreign` 函数，参数和返回值不能标注模式。
- **exclave 的使用位置**：try 块、catch 块、spawn 块、`main`、终结器和静态初始化器中不能使用 exclave，详见 [exclave 表达式](./exclave.md#使用限制)。

<!-- verify -->
<!-- cfg="--experimental --enable-local-mode" -->

```cangjie
var lastError: Exception = Exception()

func sumInThread(n: Int64): Int64 {
    let limit: Int64 @local! = n // Int64 is Copyable, can be used in spawn
    let fut = spawn {
        let squares = Array<Int64>(limit, {i => i * i}) @local! // local to the spawn block
        var sum = 0
        for (i in 0..squares.size) {
            sum += squares[i]
        }
        sum
    }
    fut.get()
}

func check() {
    try {
        throw Exception("bad input")
    } catch (e: Exception) {
        lastError = e // OK, e is @~local
    }
}

main() {
    println(sumInThread(4))
    check()
    println(lastError.message)
}
```

执行结果为：

```text
14
bad input
```

<!-- compile.error -->
<!-- cfg="--experimental --enable-local-mode" -->

```cangjie
func f() {
    let s: String @local? = "s"
    spawn {
        println(s) // Error, cannot use a @local? variable declared outside spawn
    }
}

func g(e: Exception @local?) {
    throw e // Error, the thrown value must be @~local
}

func id<T>(x: T): Unit {}

func h() {
    let s: String @local! = "s"
    id(s) // Error, the parameter x: T is @~local
}

@C
func fromC(p: CPointer<Int8> @local!): Unit {} // Error, @C function cannot use modal types
```

泛型函数要接收 local 值时，把形参标注为 `@local?`：

<!-- verify -->
<!-- cfg="--experimental --enable-local-mode" -->

```cangjie
func count<T>(xs: Array<T> @local?): Int64 {
    xs.size
}

main() {
    let xs: Array<String> @local! = ["a", "b", "c"]
    println(count(xs))
}
```

执行结果为：

```text
3
```

## 其他限制速查

以下限制不常遇到，这里只简要列出，括号内为对应的诊断 ID：

1. 终结器的 `this` 模式必须是所有构造函数 `this` 模式的父类型。例如同时有 `this @~local` 和 `this @local!` 的构造函数时，终结器需写成 `~init(this @local?)`（`sema_finalizer_this_mode_mismatch`）。
2. 如果一个类型的构造函数能构造出不同模式的实例，那么它的非 `Copyable` 类型的成员变量不能在声明处写初始值，`demode` 成员变量除外（`sema_member_var_initalizer_in_mixed_init`）。
3. 同名的实例成员属性可以按模式重载，但它们的数据类型必须相同（`sema_prop_redefinition`）。
4. 静态成员属性不能按模式重载（`sema_static_prop_overload`）。
5. `abstract` 函数不能用 `exclave` 修饰（`sema_abstract_exclave_func`）。
6. 在 exclave 之外，`@local!` 参数不能直接作为实参传给其他函数，见[传递 @local! 参数](#传递-local-参数)（`sema_external_local_arg`）。
7. 对 `@local!` 参数做模式匹配时，绑定得到的变量是 `@local?` 而不是 `@local!`。
8. `this` 模式说明只能用于实例成员函数和构造函数，写在全局函数或静态函数上会报错（`parse_unexpected_this_param`）。
9. 模式只能写在构造调用之后，如 `C() @local!`，写在普通函数调用之后会报错（`sema_mode_on_non_constructor_call`）。
10. 访问按模式重载的属性时，如果没有与实例模式匹配的版本会报错（`sema_no_match_prop_accessor_for_call`）。
