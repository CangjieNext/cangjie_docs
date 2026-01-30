# 属性

属性（Properties）提供了一个getter和一个可选的setter来间接获取和设置值。

使用属性的时候与普通变量无异，只需要对数据操作，对内部的实现无感知，可以更便利地实现访问控制、数据监控、跟踪调试、数据绑定等机制。

属性在使用时可以作为表达式或被赋值。此处以类和接口为例进行说明，但属性不仅限于类和接口。

以下是一个简单的例子，b是一个典型的属性，封装了外部对a 的访问：

<!-- verify -->

```cangjie
class Foo {
    private var a = 0

    public mut prop b: Int64 {
        get() {
            println("get")
            a
        }
        set(value) {
            println("set")
            a = value
        }
    }
}

main() {
    var x = Foo()
    let y = x.b + 1 // get
    x.b = y // set
}
```

此处Foo提供了一个名为b 的属性，针对getter/setter这两个功能，仓颉提供了get和 set两种语法来定义。当一个类型为Foo的变量x 在访问b 时，会调用b 的get操作返回类型为Int64的值，因此可以用来与1 相加；而当x 在对b 进行赋值时，会调用b 的set操作，将y 的值传给set的 value，最终将value的值赋值给a。

通过属性b，外部对Foo的成员变量a 完全不感知，但却可以通过b 做到同样地访问和修改操作，实现了有效的封装性。所以程序的输出如下：

```text
get
set
```

## 属性定义

属性可以在interface、class、struct、enum、extend中定义。

一个典型的属性语法结构如下：

<!-- compile -->

```cangjie
class Foo {
    public prop a: Int64 {
        get() { 0 }
    }
    public mut prop b: Int64 {
        get() { 0 }
        set(v) {}
    }
}
```

其中使用prop声明的a 和b 都是属性，a和 b的类型都是 `Int64`。a是无 `mut` 修饰符的属性，这类属性有且仅有定义getter（对应取值）实现。b是使用 `mut` 修饰的属性，这类属性必须分别定义getter（对应取值）和setter（对应赋值）的实现。

> **注意：**
>
> 对于数值、元组、函数、`Bool`、`Unit`、`Nothing`、`String`、`Range` 和 `enum` 类型，在它们的扩展和声明中不能声明mut修饰的属性，也不能实现有mut属性的接口。

属性的getter和 setter分别对应两个不同的函数。

1. getter函数类型是 `() -> T`，T是该属性的类型，当使用该属性作为表达式时会执行getter函数。
2. setter函数类型是 `(T) -> Unit`，T是该属性的类型，形参名需要显式指定，当对该属性赋值时会执行setter函数。

getter和 setter的实现中可以和函数体一样包含声明和表达式，与函数体的规则一样，详见[函数体](../function/define_functions.md#函数体)章节。

setter中的参数对应的是赋值时传入的值。

<!-- compile -->

```cangjie
class Foo {
    private var j = 0
    public mut prop i: Int64 {
        get() {
            j
        }
        set(v) {
            j = v
        }
    }
}
```

需要注意的是，在属性的getter和 setter中访问属性自身属于递归调用，与函数调用一样可能会出现死循环的情况。

### 修饰符

可以在 `prop` 前面声明需要的修饰符。

<!-- compile -->

```cangjie
class Foo {
    public prop a: Int64 {
        get() {
            0
        }
    }
    private prop b: Int64 {
        get() {
            0
        }
    }
}
```

和成员函数一样，成员属性也支持 `open`、`override`、`redef` 修饰，所以也可以在子类型中覆盖/重定义父类型属性的实现。

子类型覆盖父类型的属性时，如果父类型属性带有 `mut` 修饰符，则子类型属性也需要带有 `mut` 修饰符，同时也必须保持一样的类型。

如下代码所示，A中定义了x 和y 两个属性，B中可以分别对x 和y 进行 `override`/`redef`：

<!-- compile -->

```cangjie
open class A {
    private var valueX = 0
    private static var valueY = 0

    public open prop x: Int64 {
        get() { valueX }
    }

    public static mut prop y: Int64 {
        get() { valueY }
        set(v) {
            valueY = v
        }
    }
}
class B <: A {
    private var valueX2 = 0
    private static var valueY2 = 0

    public override prop x: Int64 {
        get() { valueX2 }
    }

    public redef static mut prop y: Int64 {
        get() { valueY2 }
        set(v) {
            valueY2 = v
        }
    }
}
```

### 抽象属性

类似于抽象函数，在 `interface` 和抽象类中也可以声明抽象属性，这些抽象属性没有实现。

<!-- compile -->

```cangjie
interface I {
    prop a: Int64
}

abstract class C {
    public prop a: Int64
}
```

当实现类型实现 `interface` 或者非抽象子类继承抽象类时，必须要实现这些抽象属性。

与覆盖的规则一样，实现类型或子类在实现这些属性时，如果父类型属性带有 `mut` 修饰符，则子类型属性也需要带有 `mut` 修饰符，同时也必须保持一样的类型。

<!-- compile -->

```cangjie
interface I {
    prop a: Int64
    mut prop b: Int64
}
class C <: I {
    private var value = 0

    public prop a: Int64 {
        get() { value }
    }

    public mut prop b: Int64 {
        get() { value }
        set(v) {
            value = v
        }
    }
}
```

通过抽象属性，可以让接口和抽象类对一些数据操作能以更加易用的方式进行约定，相比函数的方式要更加直观。

如下代码所示，如果要对一个size值的获取和设置进行约定，使用属性的方式 (I1) 相比使用函数的方式 (I2) 代码更少，也更加符合对数据操作的意图。

<!-- verify -->

```cangjie
interface I1 {
    mut prop size: Int64
}

interface I2 {
    func getSize(): Int64
    func setSize(value: Int64): Unit
}

class C <: I1 & I2 {
    private var mySize = 0

    public mut prop size: Int64 {
        get() {
            mySize
        }
        set(value) {
            mySize = value
        }
    }

    public func getSize() {
        mySize
    }

    public func setSize(value: Int64) {
        mySize = value
    }
}

main() {
    let a: I1 = C()
    a.size = 5
    println(a.size)

    let b: I2 = C()
    b.setSize(5)
    println(b.getSize())
}
```

```text
5
5
```

## 属性使用

属性分为实例成员属性和静态成员属性。成员属性的使用和成员变量的使用方式一样，详见[成员变量](./class.md#class-成员变量)章节。

<!-- verify -->

```cangjie
class A {
    public prop x: Int64 {
        get() {
            123
        }
    }
    public static prop y: Int64 {
        get() {
            321
        }
    }
}

main() {
    var a = A()
    println(a.x) // 123
    println(A.y) // 321
}
```

结果为：

```text
123
321
```

无 `mut` 修饰符的属性类似 `let` 声明的变量，不能被赋值。

<!-- compile.error -->

```cangjie
class A {
    private let value = 0
    public prop i: Int64 {
        get() {
            value
        }
    }
}

main() {
    var x = A()
    println(x.i) // OK
    x.i = 1 // Error
}
```

带有 `mut` 修饰符的属性类似 `var` 声明的变量，可以取值也可以被赋值。

<!-- verify -->

```cangjie
class A {
    private var value: Int64 = 0
    public mut prop i: Int64 {
        get() {
            value
        }
        set(v) {
            value = v
        }
    }
}

main() {
    var x = A()
    println(x.i) // OK
    x.i = 1 // OK
}
```

```text
0
```
