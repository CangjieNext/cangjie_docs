# 类型转换

仓颉不支持不同类型之间的隐式转换（子类型天然是父类型，所以子类型到父类型的转换不是隐式类型转换），类型转换必须显式地进行。下面将依次介绍 `is` 和 `as` 操作符。

关于数值类型（整数类型与浮点类型）之间的转换，请参见[数值类型之间的转换](../basic_data_type/integer.md#数值类型之间的转换)。关于 `Rune` 和整数类型之间的转换，请参见[`Rune` 到 `UInt32` 和整数类型到 `Rune` 的转换](../basic_data_type/integer.md#rune-到-uint32-和整数类型到-rune-的转换)。

## `is` 和 `as` 操作符

仓颉支持使用 `is` 操作符来判断某个表达式的类型是否是指定的类型（或其子类型）。具体而言，对于表达式 `e is T`（`e` 可以是任意表达式，`T` 可以是任何类型），当 `e` 的运行时类型是 `T` 的子类型时，`e is T` 的值为 `true`，否则 `e is T` 的值为 `false`。

下面的例子展示了 `is` 操作符的使用：

<!-- verify -->

```cangjie
open class Base {
    var name: String = "Alice"
}

class Derived <: Base {
    var age: UInt8 = 18
}

main() {
    let a = 1 is Int64
    println("Is the type of 1 'Int64'? ${a}")
    let b = 1 is String
    println("Is the type of 1 'String'? ${b}")

    let b1: Base = Base()
    let b2: Base = Derived()
    var x = b1 is Base
    println("Is the type of b1 'Base'? ${x}")
    x = b1 is Derived
    println("Is the type of b1 'Derived'? ${x}")
    x = b2 is Base
    println("Is the type of b2 'Base'? ${x}")
    x = b2 is Derived
    println("Is the type of b2 'Derived'? ${x}")
}
```

上述代码的执行结果为：

```text
Is the type of 1 'Int64'? true
Is the type of 1 'String'? false
Is the type of b1 'Base'? true
Is the type of b1 'Derived'? false
Is the type of b2 'Base'? true
Is the type of b2 'Derived'? true
```

`as` 操作符可以用于将某个表达式的类型转换为指定的类型。因为类型转换有可能会失败，所以 `as` 操作返回的是一个 `Option` 类型。具体而言，对于表达式 `e as T`（`e` 可以是任意表达式，`T` 可以是任何类型），当 `e` 的运行时类型是 `T` 的子类型时，`e as T` 的值为 `Option<T>.Some(e)`，否则 `e as T` 的值为 `Option<T>.None`。

下面的例子展示了 `as` 操作符的使用（注释中标明了 `as` 操作的结果）：

<!-- compile -->

```cangjie
open class Base {
    var name: String = "Alice"
}

class Derived <: Base {
    var age: UInt8 = 18
}

let a = 1 as Int64 // a = Option<Int64>.Some(1)
let b = 1 as String // b = Option<String>.None

let b1: Base = Base()
let b2: Base = Derived()
let d: Derived = Derived()
let r1 = b1 as Base // r1 = Option<Base>.Some(b1)
let r2 = b1 as Derived // r2 = Option<Derived>.None
let r3 = b2 as Base // r3 = Option<Base>.Some(b2)
let r4 = b2 as Derived // r4 = Option<Derived>.Some(b2)
let r5 = d as Base // r5 = Option<Base>.Some(d)
let r6 = d as Derived // r6 = Option<Derived>.Some(d)
```

### 类型模式与子类型转换

类型模式也可以用于子类型转换。对于表达式 `e` 和类型模式 `id: T`，当 `e` 的运行时类型是 `T` 的子类型时，匹配成功，并将 `e` 转换为 `T` 类型后与 `id` 进行绑定；否则匹配失败，并进入其他分支。

与 `is` 操作符用于类型判断、`as` 操作符返回 `Option` 不同，类型模式匹配成功后可直接得到对应子类型的绑定变量。这里的子类型转换，是指根据运行时类型将父类型的值收窄为子类型。模式中绑定出的变量仅在匹配成功的分支或循环体内有效。

在 `if` 表达式和 `while` 表达式的条件中，可以通过 “let pattern” 使用类型模式。

关于类型模式的更多介绍，请参见[类型模式](../enum_and_pattern_match/pattern_overview.md#类型模式)。关于 “let pattern” 的更多介绍，请参见[涉及 “let pattern” 的“条件”示例](../basic_programming_concepts/expression.md#涉及-let-pattern-的条件示例)。

下面的例子展示了在 `if` 表达式和 `while` 表达式的条件中使用类型模式进行子类型转换：

<!-- verify -->

```cangjie
open class Base {
    var name: String = "Alice"
}
class Derived <: Base {
    var age: UInt8 = 18
}

main() {
    let b1: Base = Base()
    let b2: Base = Derived()
    var b3: Base = Derived()

    if (let d: Derived <- b1) {
        println("The age of b1 is ${d.age}")
    } else {
        println("b1 is not Derived")
    }

    if (let d: Derived <- b2) {
        println("The age of b2 is ${d.age}")
    } else {
        println("b2 is not Derived")
    }

    while (let d: Derived <- b3) {
        println("The age of b3 is ${d.age}")
        b3 = Base()
    }
}
```

上述代码的执行结果为：

```text
b1 is not Derived
The age of b2 is 18
The age of b3 is 18
```

上述结果中，`b1` 未匹配成功，`b2` 和 `b3` 匹配成功并完成了类型绑定。
