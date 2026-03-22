# 仓颉-Java 互操作

> **注意：**
>
> 当前版本仅支持[在仓颉侧使用 Java 的场景](#在仓颉侧使用-java)，而[在 Java 侧使用仓颉的场景](#在-java-侧使用仓颉)则尚不支持。

仓颉跨平台方案支持开发者将仓颉语言接入 Android/iOS 应用开发，无论是项目中尚未实现的新逻辑，还是已存在的存量逻辑，都可通过仓颉语言完成开发与适配。

镜像类型是仓颉跨平台实现跨语言、跨运行时互操作的核心机制。它允许一门语言中定义的类型向另一门语言暴露接口，进而实现该类型在不同语言环境中的直接使用。

在仓颉侧，借助镜像类型，开发者无需脱离仓颉语法与语义规范，即可让仓颉类继承 Java 类/ Objective-C 类，实现 Java 接口/Objective-C 协议，而在 Java/Objective-C 侧，镜像类型同样能够让仓颉类型以对应语言的原生类型形式呈现。

在仓颉侧，镜像类型使得在依旧遵循仓颉语法和语义的情况下，仓颉 class 能够继承 Java 的 class/ Objective-C 的 interface，实现 Java 的 interface/Objective-C 的 protocol。而在 Java/Objective-C 侧，镜像类型同样能够使得仓颉类型以各自语言的类型表示出来。总体来说，仓颉跨平台让仓颉和 Java/Objective-C 在 Android/iOS 应用工程中做到尽可能无缝衔接，同时也意味着，开发者可以在仓颉代码中，通过跨语言互操作直接调用对应操作系统提供的 API 。

## 挑战与解决方法

仓颉、 Java 和 Objective-C 虽然都是支持继承和多态的面向对象范式语言，但其各自的语义、底层实现的对象模型和执行模型等却存在显著差异，因此，试图在 Java/Objective-C 代码中直接使用仓颉语言，或反之在仓颉代码中直接使用 Java/Objective-C ，均无法实现。

三种语言均各自拥有不同于其他两种语言的托管运行时，自动内存管理、线程模型、异常处理等底层特性各不相同。让两个复杂编程语言的运行时通过相互感知来实现互操作，无疑会让整个应用的复杂度剧增。

因此，仓颉跨平台对于仓颉与 Java 的互操作的实现思路是分别站在仓颉和 Java 侧，均将另一方视作低级语言。具体来说，仓颉与 Java 通过 Java 本地接口（ JNI ）实现互通。众所周知，JNI 用于使能 Java 调用例如 C/C++ 开发的本地接口，虽然功能强大，但作为底层 API ，手写绑定层费时费力，不过好在 CJMP 提供了相应工具链，有效地消减了使用复杂度。

Objective-C 的运行时模块 API 在 iOS 平台上担任了与 JNI 在安卓平台上类似的角色，其也是为实现 Objective-C 与其他语言之间的桥接层。与上述的 JNI 的情况一样， CJMP 同样为开发者消减了其使用时繁琐的部分。

## 核心概念

### 镜像类型

不妨这样理解什么是镜像类型：仓颉和 Java 一对语言之间进行互操作，若一种语言 A 的源码中定义有镜像类型`T'`，则意味着在另一种语言 B 的源码中实际存在由 B 语言定义的类型`T`。于是，在语言 A 的源码中就可以通过直接使用镜像类型`T'`来实现间接使用类型`T`，最终实现语言 A 仿佛直接使用语言 B 的类型的效果。该操作存在特定限制，将在下文中详细说明。

诸如布尔类型和数值类型等两种语言之间本质上等价的类型天然就是相互的镜像类型，例如， Java 视角下，其`int`类型就是仓颉`Int32`类型在 Java 侧的镜像类型；反过来，仓颉视角下，其`Int32`类型就是 Java `int`类型在仓颉侧的镜像类型。不过，对于部分无法建立对应关系的数值类型来说，这个镜像关系就是不存在的了，例如仓颉的`Float16`在 Java 侧就没有任何类型能够与之对应，故在 Java 视角下就不存在一种镜像类型来匹配仓颉的`Float16`类型，也可以理解为，仓颉的`Float16`类型无法被镜像为任何 Java 基本类型。

对于`class`、`struct`、`interface`和`enum`等用户自定义类型，语言 A 中的类型`T`在另一门语言 B 中的镜像类型`T'`，是在语言 B 中所能找到的尽可能最佳的等价类型。举例来说，仓颉的`struct`或元组类型在 Java 中所能找到的最佳等价类型是 Java 的`final class`类型。

若要在语言 B 中通过镜像类型使用语言 A 定义的类型，该镜像类型仅会暴露语言 A 原生类型中“理论上可被语言 B 访问和调用”的成员与构造函数。举例来说：若某个仓颉成员函数的返回类型为`Float16`，由于`Float16`无法被镜像为 Java 类型，该仓颉成员函数也无法生成对应的镜像，导致 Java 侧无法通过镜像类型调用此函数，这类场景需根据实际情况采用特定技巧解决。

正常情况下，无论是仓颉类型的镜像类型还是 Java 类型的镜像类型，以及镜像类型本身依赖的其他类型的镜像类型，都能够以某种方式自动生成获得。 CJMP 提供了一个独立的工具—— Java 镜像生成器，来实现为 Java 类型自动生成镜像类型；为仓颉类型生成镜像类型也同样是自动完成的，加上特定编译选项的 cjc 编译过程会将仓颉类型的镜像类型定义作为副产品生成，具体步骤将在本文档中详细解释。

#### 将 Java 类型镜像为仓颉类型

 cjc 在编译过程中会将所有仓颉源码中用到的 Java 镜像类型替换为相应的胶水代码，这意味着，真正对编译结果起作用的核心信息只有两点：一是被使用的 Java 镜像类型的名称，二是该镜像类型中各可用成员的名称及其类型。因此在编写仓颉代码时，Java 镜像类型定义中只需要包含各个可用成员的声明就够了，换句话说，Java 镜像类型中并不需要保留构造函数体、成员函数体和成员属性体，成员变量也不需要初始化器。另一方面，Java 类型中定义的`private`与包内私有的成员对仓颉侧来说不可见，因此这类成员同样不会出现在 Java 镜像类型定义中。

显然，上述 Java 镜像类型定义的写法是不符合仓颉语法/语义规格的，故 Java 镜像类型定义必须带有`@JavaMirror`注解，该注解用于在编译期协助 cjc 区分正常的仓颉类型定义与 Java 镜像类型定义，从而对后者进行特殊处理。

示例如下，假设存在如下的 Java  `class`：

```java
public class Node {
    public static final int A = 0xDeadBeef;
    private int _id;
    public Node(int id) { _id = id; }
    public int id() { return _id; }
}
```

其对应的 Java 镜像类型定义可能如下：

```cangjie
@JavaMirror
public open class Node {
    public static let A: Int32
    public init(id: Int32)
    public open func id(): Int32
}
```

值得一提的是，互操作库中预置了几个基础的 Java 类型的镜像类型，即`java.lang.Object`、`java.lang.String`和 Java 数组类型，详情请参见[互操作库预置 API 参考](#互操作库预置-api-参考)。

#### 将仓颉类型镜像为 Java 类型

由于 cjc 专门的处理， Java 镜像类型定义只需要保留最核心的信息即可，但仓颉镜像类型定义则必须是完整的正常的 Java 类型定义，因为安卓工具链不会提供任何额外的特殊处理。在编译过程中，cjc 会将仓颉镜像类型定义生成为 Java 源文件形式，该类型定义中包含完整的胶水层代码，这部分代码实现了仓颉与 Java 两个运行环境之间的交互衔接。

假设前一个例子中的`Node`类型是由仓颉定义实现的，示例如下：

```cangjie
public class Node {
    private let _id: Int
    public prop id: Int {
        get() { _id }
    }
    public init(id: Int) { this._id = id }
}
```

那么 cjc 在编译上述代码块时将为其自动生成以下的仓颉镜像类型定义：

```java
public final class Node {
    /* 胶水代码 */
    public Node(long id) {
        /* 此处胶水代码将构造仓颉 Node 类的实例，
         * 并将其与当前正在构造的 Java Node 类的实例（即 `this`）关联。
         */
    }
    public long getId() {
        /* 此处胶水代码将调用 `this` 所关联的仓颉 Node 类实例的 `id` 成员属性，
         * 并将调用结果作为该方法的返回值。
         */
     }
    /* 其他胶水代码 */
}
```

### 互操作类

互操作类本质上是一个仓颉`class`，其从一到若干个镜像类型派生而来，这种仓颉`class`能够被 Java 侧使用，这是因为其所有构造函数和非继承而来的`public`成员函数，都会通过一个由 cjc 在编译它时自动生成的共轭的 Java 包装类，对 Java 代码暴露。这个 Java 包装类本身可能会定义若干辅助方法，但对于 Java 侧代码来说，能调用的方法只有从仓颉侧暴露而来的，以及该 class 继承而来的；仓颉侧代码也是同理。

接下来将举例说明，当使用 cjc 编译以下互操作类时：

```cangjie
@JavaImpl
public class BooleanNode <: Node {
    private let flag: Bool
    public init(id: Int32, flag: Bool) {
        super.init(id)
        this.flag = flag
    }
    public func getFlag(): Bool {
        flag
    }
}
```

 cjc 将同时生成一份 Java 源码，其内容类似于以下代码块：

```java
public class BooleanNode extends Node {
    /* 胶水代码 */
    public BooleanNode(int id, boolean flag) {
        /* 胶水代码，构造一个 Java 的 BooleanNode 包装类实例，
         * 并将其与仓颉侧的 BooleanNode 实例关联起来
         */
    }
    public boolean getFlag() {
        /* 胶水代码，调用该 Java 的 BooleanNode 包装类实例所关联的
         * 仓颉 BooleanNode 实例的'getFlag'实例成员函数，并返回调用结果
         */
    }
    /* 其他胶水代码 */
}
```

#### 外部类型

镜像类型和互操作类均有别于真正原生的自定义类型，故简洁起见，本文档中它们将被统一称作外部类型。

### Java 兼容类型

以下仓颉类型均为 Java 兼容类型：

* 所有拥有等价的 Java 基本类型的仓颉值类型，例如`Int16`拥有等价的 Java 基本类型`short`，故`Int16`为 Java 兼容类型；而`UInt8`无等价的 Java 基本类型，故`UInt8`不是 Java 兼容类型
* 所有外部类型
* `Option<T>`类型，且其中类型变元`T`为外部类型

互操作库中预置的特殊泛型镜像类型`JArray<T>`对应 Java 的数组类型，其类型变元`T`必须是 Java 兼容类型。

显然，外部类型定义中的`public`成员函数的形参类型和返回类型必须是 Java 兼容类型，否则将导致 cjc 编译报错。

互操作类的`public`成员变量的类型可以是任意类型，但只有当成员变量的类型为 OC 兼容类型时，该成员变量才可以在仓颉和 OC 侧均可访问。

```cangjie
@JavaImpl
class NamedNode <: Node {
    public var jName: JString  /* 该实例成员变量保存在互操作类的共轭 Java 包装类实例中 */
    public var cjName: String  /* 该实例成员变量保存在互操作类实例中 */
    init(name: JString) {
        jName = name
        cjName = name.toCangjieString()
    }
}
```

### 互操作的使用场景

总体来说，共存在两种 Java/仓颉互操作的使用场景：

* 仓颉侧所定义的类型和函数通过互操作对 Java 侧代码暴露，从而使得 Java 侧可以使用仓颉提供的 API 、仓颉库与其他应用组件等。
* Java 侧所定义的类型通过互操作对仓颉侧代码暴露，从而使得仓颉侧可以间接调用安卓 API 、Java 三方库与其他尚使用 Java 编写的应用组件。

上述使用场景并非完全互斥，单个应用程序中完全可能同时存在上述两种使用场景。此外，两种使用场景中均支持类继承和接口实现， Java 类可以继承仓颉类，实现仓颉接口，而仓颉类也可以继承 Java 类，实现 Java 接口，这使得在两种使用场景下均并非单向的从仓颉调用 Java 或从 Java 调用仓颉，而是仓颉和 Java 之间灵活地互相调用，控制流得以互相转交。

由于两种场景各自拥有的功能特性、使用限制条件和工具支持情况等具有明显差别，下文将分别对两种使用场景进行阐述。

## 在 Java 侧使用仓颉

 Java 侧访问仓颉库、调用仓颉 API 等的前提是开发者提前为所有相关的仓颉类型生成 Java 侧能够使用的镜像类型。 cjc 在编译仓颉源码过程中能够自动生成所需的镜像类型定义，详情请参见[仓颉镜像生成参考](#仓颉镜像生成参考)。

> **注意：**
>
> 仓颉语言的类型系统比 Java 的更加丰富和灵活，即便是某些共有的语言特性，本质上也存在巨大差异，其中最典型的是[泛型](#为泛型仓颉类型进行镜像)，因此部分仓颉的语言特性完全无法在 Java 中表达，而部分则难以用自然优雅的方式来表达。具体支持和限制情况请参见[仓颉到 Java 的映射](#由仓颉到-java-的映射关系)。

**例子:**

假设存在以下仓颉`struct Vector`类型需要暴露给 Java 侧使用：

```cangjie
package cj

public struct Vector {
    private var x: Int32 = 0
    private var y: Int32 = 0

    public init(x: Int32, y: Int32) {
        this.x = x
        this.y = y
    }

    public func add(v: Vector): Vector {
        Vector(x + v.x, y + v.y)
    }
}
```

在编译上述代码块时需为 cjc 新增两个额外的编译选项：`--experimental`和`--enable-interop-cjmapping=Java`，编译成功后将额外生成一个 Java 源文件`Vector.java`，其中的内容类似如下：

```java
package cj;

public final class Vector {
    // 胶水代码

    public Vector(int x, int y) { /* 胶水代码 */ }

    public Vector add(Vector v) { /* 胶水代码 */ }

    // 其他胶水代码
}
```

将`Vector.java`集成进安卓工程中，比如放置到`src/main`目录下，接着就可以将这个`Vector`类型当作本来就是 Java 编写的一样的类型来使用了：在 Java 代码中定义`Vector`类型的变量，创建`Vector`类型的实例，将实例作为方法入参，例如调用`Vector.add`方法并将`Vector`类型的实例传入等。

### 限制暴露面

 cjc 编译选项`--enable-interop-cjmapping`使得其所编的仓颉包中所有的`public`用户自定义类型均生成仓颉镜像类型，且这些用户自定义类型中的所有`public`成员和构造函数都会被暴露给 Java 侧。但在实际开发场景中，这种全盘暴露的方式通常没有必要，因为 Java 侧需要直接调用的仓颉接口，往往仅占整个仓颉库的很小一部分。

开发者可以通过 cjc 编译选项`--import-interop-cj-package-config-path`来指定一个配置文件的路径，该配置文件使得开发者可以精确控制仓颉用户自定义类型及其成员的暴露范围。该配置文件为纯文本，格式遵循 TOML 语法。

该配置文件的`[default]`配置块中，开发者可以指定对所有仓颉包的默认 API 暴露策略，如果需要，还可以在对应的`[[packages]]`配置块中对特定的仓颉包的暴露策略进行修改，示例如下：

```toml
[default]
APIStrategy = "None"       # 对于所有仓颉包，默认不暴露任何实体

[[packages]]
name = "com.example.pkg1"  # 而对于该仓颉包，
APIStrategy = "Full"       # 默认暴露所有实体
# ...（后接下方代码块）
```

而对于每个仓颉包，开发者可以使用`included_apis`或`exluded_apis`配置项来指定暴露哪些类型/成员，隐藏哪些类型/成员，示例如下：

```toml
# ...（前接上方代码块）
[[packages]]
name = "com.example.pkg2"  # 对于该仓颉包，
included_apis = [          # 仅暴露
    "Vector",              # 类型 `Vector`
    "Vector.add"           # 以及其成员函数 `add`。
]

[[packages]]
name = "com.example.pkg3"  # 而对于该仓颉包，
APIStrategy = "Full"       # 默认暴露所有实体，
excluded_apis = [          # 但其中的
    "TopSecret",           # 类型 `TopSecret`
    "Auth.getPwd"          # 以及类型 `Auth` 的成员函数 `getPwd`
]                          # 不被暴露。
```

详情请参见[仓颉镜像生成参考](#仓颉镜像生成参考)。

## 为泛型仓颉类型进行镜像

由于仓颉和 Java 的泛型特性的实现存在根本性差异，仓颉泛型类型无法直接映射到 Java 泛型类型以得到仓颉镜像类型。作为替代方案， CJMP 支持了仓颉镜像类型的单态化：用户通过配置文件为每个给定的仓颉泛型类型指定一个类型实参组合的列表， cjc 根据这个列表，对每个类型实参组合分别单独为该仓颉泛型类型生成一个非泛型的仓颉镜像类型，于是在 Java 侧使用的都是非泛型的仓颉镜像类型。

> **注意：**
>
> 当前版本仅支持基本数据类型作为类型实参来单态化仓颉泛型类型。

举例来说，假设仓颉侧定义有如下泛型类型：

```cangjie
package p

public class Pair<T, U> { /* ... */ }
```

如果希望在 Java 侧能够使用`Pair<Int, String>`和`Pair<Foo, Bar>`两种类型，开发者可以在配置文件中`name`为`p`的`[[packages]]`配置块中，新增`generic_object_configuration`配置项，具体配置内容如下：

```toml
# ...
[[packages]]
name = "p"
generic_object_configuration = [
    { name = "Pair",
      type_arguments = [
          "Int, String",
          "Foo, Bar"
      ] },
# ...
]
```

 cjc 将生成以下两个 Java 类：

```java
public final class GIntString { /* ... */ }

public final class GFooBar { /* ... */ }
```

分别对应了`Pair<T, U>`的两种特定的实例化情况。

> **注意：**
>
> 当前版本仅支持布尔类型和数值类型作为用于单态化的类型实参，因此上述例子中的`Pair<Foo, Bar>`实际上并不支持，仅处于示例目的，实际上并无法成功暴露。

详情请参见[仓颉镜像生成参考](#仓颉镜像生成参考)的泛型实例化相关部分。

## 由仓颉到 Java 的映射关系

当前版本的 cjc 采用本章所描述的仓颉到 Java 的映射规则。关于相关的 cjc 命令行选项请参见[仓颉镜像生成参考](#仓颉镜像生成参考)。

### 一般注意事项

仓颉语言的类型系统较 Java 而言更为丰富，不少仓颉类型及其相应的特性在 Java 中并不存在直接对应的等价的类型，有些则甚至连近似的类型也不存在，故在当前 CJMP 版本中，部分仓颉类型仅提供有限支持，而部分则完全不支持。

由于上述的限制，如果用户自定义类型中的`public`成员函数/构造函数的形参类型/返回类型不存在对应的镜像类型，该成员函数/构造函数本身也无法被镜像，并且 cjc 将报错表示不支持。不过，如果这种不存在对应镜像类型的类型是被用在一个本来就不支持镜像的上下文中，例如，将`Float16`类型用作`public`成员变量的类型，由于本来就不支持镜像成员变量，于是 cjc 既不会报错也不会警告，而只是单纯不对其进行镜像。

#### 仓颉类型别名

仓颉类型别名声明不会被镜像，而所有仓颉语言结构在被镜像时，其中包含的类型别名都会被视作已经被替换为实际类型，在 Java 侧看来并不会感知到仓颉侧的类型别名。

### 仓颉名称

仓颉包名、函数名、类型名称和类型成员的名称在镜像结果中都会完整保留原名，这也意味着，可能存在镜像后与 Java 关键字冲突的情况，例如`int`、`final`等，或镜像类型中包含 Java 禁止的用于构成名称的字符。

### 仓颉布尔类型与数值类型

对于仓颉布尔类型和数值类型，如果在 Java 中存在对应等价类型，将被镜像为其对应类型，否则不支持镜像，详情请参见下表：

仓颉类型 |  Java 类型
------------- | ----------------
`Bool`        | `boolean`
`Int8`        | `byte`
`Int16`       | `short`
`Int32`       | `int`
`Int64`       | `long`
`IntNative`   | 不支持
`UInt8`       | 不支持
`UInt16`      | `char`
`UInt32`      | 不支持
`UInt64`      | 不支持
`UIntNative`  | 不支持
`Float16`     | 不支持
`Float32`     | `float`
`Float64`     | `double`

关于如何处理不支持的类型，请参见[由仓颉到 Java 的映射关系](#由仓颉到-java-的映射关系)章节的一般注意事项。

### 仓颉`Rune`类型

不支持仓颉`Rune`类型。

关于如何处理不支持的类型，请参见[由仓颉到 Java 的映射关系](#由仓颉到-java-的映射关系)章节的一般注意事项。

### 仓颉`String`类型

仓颉`String`类型当前尚不支持。

关于如何处理不支持的类型，请参见[由仓颉到 Java 的映射关系](#由仓颉到-java-的映射关系)章节的一般注意事项。

### 仓颉`Array<T>`类型

仓颉`Array<T>`类型当前尚不支持。

关于如何处理不支持的类型，请参见[由仓颉到 Java 的映射关系](#由仓颉到-java-的映射关系)章节的一般注意事项。

### 仓颉元组类型

仓颉元组类型被镜像为 Java 的`final class`，相应的 Java 侧类型定义由 cjc 在编译过程中自动生成，类型定义中包含胶水层代码，实现在 Java 和仓颉之间传递控制和数据。自动生成的胶水层代码原则上禁止手动修改。

```cangjie
package tuples

import interoplib.interop

public class SimpleTupleExample {
    public static func z(): (Int, Int) {
        (0, 0)
    }
}
```

```java
// 位于源文件 java-gen/SimpleTupleExample.java
package tuples;
// 胶水代码
public class SimpleTupleExample {
    // 胶水代码
    public static native TupleOfInt64Int64 z();
    // 胶水代码
}
```

```java
// 位于源文件 java-gen/TupleOfInt64Int64.java
package tuples;
// 胶水代码
final public class TupleOfInt64Int64 {
    // 胶水代码
    public TupleOfInt64Int64(long item0, long item1) {
        /* 此处胶水代码将构造仓颉 (Int, Int) 元组实例，
         * 并将其与当前正在构造的 Java 类的实例（即 `this`）关联。
         */
    }

    public long item0() {
        /* 此处胶水代码将取得 `this` 所关联的仓颉 (Int, Int) 元组实例的第 0 个元素，
         * 并将其作为该方法的返回值。
         */
    }

    public long item1() {
        /* 此处胶水代码将取得 `this` 所关联的仓颉 (Int, Int) 元组实例的第 1 个元素，
         * 并将其作为该方法的返回值。
         */
    }
    // 胶水代码
}
```

仓颉元组类型`(T0, T1, ..., Tn)`将被镜像为 Java 的`final class`，具体而言：

* 如果`Ti`是仓颉别名类型，在镜像时，`Ti`将被视作被别名的实际类型来处理。例如，`(Int, Int)`将被视作`(Int64, Int64)`来处理。

* 镜像结果的类型名称的规格为`TupleOfT0T1...Tn`，直观来讲就是按顺序将元组元素的仓颉类型的名称直接拼接起来，并加上`TupleOf`前缀。例如，仓颉元组类型`(Int, Int)`镜像后的 Java 类型名称为`TupleOfInt64Int64`，注意到，该例子涉及上一条类型别名替换规格。

> **注意：**
>
> 当前尚不支持不具有简单名称（非[类型别名](#仓颉类型别名)）的类型作为元组元素类型。关于如何处理不支持的类型，请参见[由仓颉到 Java 的映射关系](#由仓颉到-java-的映射关系)章节的一般注意事项。

* 镜像 Java  `final class`有且仅有一个`public`构造方法，其形参类型依次为`T0'`、`T1'`、...和`Tn'`，其中`Ti'`原仓颉侧元素类型`Ti`的 Java 侧镜像类型。调用该构造方法将实例化一个对应仓颉元组，元组元素为构造方法的实参，并将仓颉元组与本 Java 对象实例关联起来。

* 对于元组中的第`i`个元素，镜像`class`中存在一个对应的无参实例方法`public Ti' item${i}()`， Java 侧调用该方法即返回对应元素。

当前仓颉元组镜像类型的使用限制如下：

* 仓颉元组的元素类型仅支持`Bool`和数值类型。

* cjc 在编译过程中并不会自动对所有遇到的元组类型自动生成其对应的镜像类型，如果需要生成某元组类型的镜像类型，必须由用户手动显式在[配置文件](#仓颉镜像生成配置)中列举该元组类型：

    ```toml
    # ...
    [[package]]
    name = "tuples"
    tuple_configuration = [ "(Int, Int)" ]
    # ...
    ```

    如果 cjc 在编译过程中遇到任何逻辑上必须被镜像的元组类型，但该元组类型并未在配置文件中对应仓颉包的`tuple_configuration`配置项中被列举，那么 cjc 将报错提示。

* 仓颉`class`、`struct`等类型是名义性的，换句话说，即便其类型定义中的成员完全相同，只要类型名称不同，或定义在不同的仓颉包中，它们之间就被视作不同的类型。仓颉元组类型则是结构性的，即当两个元组类型具有相同数量的元素，且对应位置的元素类型相同时，它们之间就是相等的。即便元组类型出现在不同的仓颉包中，一个仓颉包中定义的`T0`元组类型的变量依然可以作为实参传给另一个仓颉包中定义的接收`T1`元组类型的函数，只要`T0`和`T1`结构性相同。然而，仓颉元组类型的镜像类型，也就是 Java 类，是名义性的，这就会导致一个问题：不同仓颉包中，即便是完全相同的仓颉元组类型，它们所生成的 Java 镜像类却是不兼容的。

* 仓颉元组类型是值类型，但其在 Java 侧的镜像类型却是引用类型，这将导致两方面的后果：

    * 多个 Java 镜像类型的变量可能实际上指向同一个仓颉侧的元组实例，不过正常来说这不会导致任何问题，因为仓颉元组本身是只读的。

    * 两种语言的比较运算符的语义完全不同。 Java 的`==`和`!=`比较运算符测试的是两个仓颉元组类型的镜像类型的实例之间的引用相等性，而仓颉元组类型的`==`和`!=`则是对仓颉元组实例的逐个元素进行相等性比较，并且要求被比较的两个元组的类型相同且元组的各元素类型均可比较。当前 CJMP 实现中，为仓颉元组类型生成的镜像类型定义中并未真正实现元组内容的比较逻辑，而仅是在重写的`equals`方法中使用抛`UnsupportedOperationException`异常占位。因此，Java 侧并不存在比较同类型元组实例的简洁的手段。

### 仓颉`Range`类型

仓颉`Range`类型当前尚不支持。

关于如何处理不支持的类型，请参见[由仓颉到 Java 的映射关系](#由仓颉到-java-的映射关系)章节的一般注意事项。

### 特殊仓颉类型

仓颉`Unit`类型仅当作为函数返回类型时，被映射为 Java 的`void`类型。

仓颉`Nothing`类型完全无法被映射，故不支持。

仓颉`Any`类型当前尚不支持。

关于如何处理不支持的类型，请参见[由仓颉到 Java 的映射关系](#由仓颉到-java-的映射关系)章节的一般注意事项。

### 仓颉函数类型

仓颉函数类型被映射为 Java 函数式接口声明：

```cangjie
package cjworld

import interoplib.interop

public class IntFuncBox {
    private let _f: (Int) -> Int
    public init(f: (Int) -> Int) { _f = f }
    public func unbox(): (Int) -> Int { _f }
}
```

```java
package cjworld;
// 胶水代码
@FunctionalInterface
public interface Int64ToInt64
{
    // 胶水代码
    public long call(long p1);
    // 胶水代码
}
```

```java
package cjworld;

// 胶水代码
public class IntFuncBox {
    // 胶水代码
    public IntFuncBox(Int64ToInt64 f) {
        /* 此处胶水代码将构造仓颉类 `IntFuncBox` 实例，
         * 并将其与当前正在构造的 Java 类的实例（即 `this`）关联。
         */
    }

    public Int64ToInt64 unbox() {
        /* 此处胶水代码将调用 `this` 所关联的仓颉实例的 `unbox()` 实例成员函数，
         * 将其返回值包装进实现了 `Int64ToInt64` 的 Java 辅助类的实例中
         * 并作为该方法返回值。
         */
    }
    // 胶水代码
}
```

仓颉函数类型`(T0, T1, ..., Tn) -> U`被镜像为 Java 函数式接口，且具有以下规格：

* 如果类型`Ti`是仓颉类型别名，则`Ti`将被视作被别名的实际类型来处理。举例来说，`(Int) -> Int`将被视作`(Int64) -> Int64`来进行镜像。

* 如果类型`Ti`和/或`U`是类型变元，则将针对每个泛型类型或成员的[单态化](#为泛型仓颉类型进行镜像)结果来分别进行镜像成不同的 Java 函数式接口。详情请参见[泛型实例化](#为泛型仓颉类型进行镜像)。

* 镜像得到的 Java 函数式接口的名称的规格是`T0T1...TnToU`，换句话说，所有函数形参的类型名称按顺序直接拼接，然后追加`To`作为分隔，最后追加上函数返回类型名称。举例来说，`(Int, Bool) -> Int`所生成的 Java 函数式接口的名称是`Int64BoolToInt64`。

> **注意：**
>
> 当前尚不支持不具有简单名称（非[类型别名](#仓颉类型别名)）的类型作为函数签名中所用到的类型。关于如何处理不支持的类型，请参见[由仓颉到 Java 的映射关系](#由仓颉到-java-的映射关系)章节的一般注意事项。

* 镜像得到的 Java 函数式接口将拥有唯一一个`public`实例方法：

    `U' call(T1' p1, T2' p2, ...Tn' pn) { ... }`

    其中`Ti'`是`Ti`的镜像类型，`U'`是`U`的镜像类型。实例方法的各形参名称为自动合成的：`p1`、 `p2`等。

* 仓颉和 Java 两侧可以通过函数类型镜像实现函数和 lambda 表达式的互传：

    * 仓颉侧可以将具有函数类型的值传递到 Java 侧，例如，Java 侧调用仓颉的一个成员函数，该成员函数返回了一个仓颉 lambda，Java 侧通过调用`call`实例方法来调用该仓颉 lambda，并传入相应的入参，得到 lambda 的返回值（如果 lambda 返回类型为`Unit`则没有返回值）。

    * 镜像得到的 Java 函数式接口，在 Java 侧既可以被 Java 类实现后实例化之，也可以与对应类型的 Java lambda 兼容。像这样的 Java 类的实例或 lambda 可以被作为入参传递到仓颉侧，胶水层中将自动合成仓颉函数类型的实例并与 Java 类实例或 Java lambda 关联，进而在仓颉侧代码中可以调用 Java 侧的函数类型实例。

当前实现具有以下限制：

* 函数形参类型仅支持`Bool`和[支持的数值类型](#仓颉布尔类型与数值类型)。

* 函数返回类型仅支持`Unit`、`Bool`和[支持的数值类型](#仓颉布尔类型与数值类型)。

* cjc 在编译过程中并不会自动对所有遇到的函数类型自动生成其对应的镜像类型，如果需要生成某函数类型的镜像类型，必须由用户手动显式在[配置文件](#仓颉镜像生成配置)中列举该函数类型：

    ```toml
    # ...
    [[package]]
    name = "lambdas"
    lambda_patterns = [
        { signature = "(Int) -> Int" },
        { signature = "(Float64) -> Bool" },
    ]
    # ...
    ```

    当 cjc 编译时遇到一个理论上必须被镜像，但事实上并未被列举在配置文件的相应仓颉包的`[[packages]]`配置块中的`lambda_patterns`配置项中的函数类型时将报错。

* 仓颉函数类型是结构性的：两个函数类型如果拥有相同的函数签名，它们就是互相兼容的。然而，由不同仓颉包中的函数类型生成的 Java 函数式接口却是互相不兼容的，即便它们各自的原仓颉函数类型完全相同。如果出现这种同一个仓颉函数类型却通过多个仓颉包暴露给 Java 的使用场景时，可能会产生问题。

* 仓颉函数类型的实例之间是不可比较的，而 Java 函数式接口的实例却可比较，不过这一般来说不构成问题。

### 仓颉`struct`类型

`public`仓颉`struct`类型定义将被镜像为 Java `final class`类型定义，相应的 Java 侧类型定义由 cjc 在编译过程中自动生成，类型定义中包含胶水层代码，实现在 Java 和仓颉之间传递控制和数据。自动生成的胶水层代码原则上禁止手动修改。

```cangjie
package cj

import interoplib.interop.*

public struct Vector {
    private var x: Int32 = 0
    private var y: Int32 = 0

    public init(x: Int32, y: Int32) {
        this.x = x
        this.y = y
    }

    public func add(v: Vector): Vector {
       let res = Vector(x + v.x, y + v.y)
       print("cj: (${x}, ${y}) + (${v.x}, ${v.y}) = (${res.x}, ${res.y})\n", flush: true)
       return res
    }

    public static func dump(v: Vector): Unit {
        print("cj: Hello from static func in cj.Vector (${v.x}, ${v.y})\n", flush: true)
    }
}
```

```java
package cj;

// 此处胶水代码将导入若干类型

final public class Vector {
    // 胶水代码

    public Vector(int x, int y) {
        // Glue code that constructs an instance of the Cangjie Vector struct
        // and associates it with the  Java  object 'this'
    }

    public Vector add(Vector v) {
        // Glue code that retrieves the associated Cangjie Vector struct
        // instances associated with `this` and `v`, calls the add() instance
        // member function of the Cangjie-this, passing the Cangjie-v to it
        // as a parameter, and, finally, creates a new  Java  Vector instance
        // and associates it with the result of the add() call.
    }

    public static void dump(Vector v) {
        // Glue code that calls the dump() static member function of the
        // Cangjie struct Vector, passing to it the instance associated
        // with 'v'/
    }

    // 胶水代码
}
```

只有`public`仓颉`struct`的`public`成员和`public`普通构造函数将被镜像。

**成员函数**被镜像为 Java 方法，其中形参类型和返回类型均被替换为对应镜像类型。返回类型为`Unit`的成员函数被镜像为返回类型为`void`的 Java 方法。`public`和`static`修饰符将被保留。

**普通构造函数**被镜像为 Java 构造方法，其中形参类型均被替换为对应镜像类型。此处普通构造函数同样包括被隐式定义的默认构造函数。`public`修饰符将被保留。

当前版本对可被镜像的`struct`类型施加了诸多严格限制，可以说需要专门为 Java 互操作量身定制`struct`：

* 成员变量不会被镜像，且 Java 侧不提供任何直接访问之的途径。该限制将在未来版本中移除，不过当前开发者可以通过在仓颉侧定义相应的`getter`成员函数作为临时解决方案。

* `mut`实例成员函数的镜像尚在实现中。它们会被镜像，但生成的胶水层代码在某些情况下是错误的。

* 不支持被镜像的`struct`实现有除`Any`外的任何`interface`，否则将导致编译报错。

* 支持通过单态化为泛型`struct`类型生成镜像，详情请参见[仓颉泛型](#仓颉泛型)章节。

* 不支持被镜像的`struct`中包含`public`成员属性、操作符重载函数和主构造器，否则将导致编译报错。

* 被镜像的`struct`中，如果被镜像的成员函数或构造函数的形参类型或返回类型中存在不支持的类型，将导致编译报错。

### 仓颉`class`与`interface`类型

仓颉`class`和`interface`类型定义分别被镜像为 Java 的`class`和`interface`定义。相应的 Java 侧类型定义由 cjc 在编译过程中自动生成，类型定义中包含胶水层代码，实现在 Java 和仓颉之间传递控制和数据。自动生成的胶水层代码原则上禁止手动修改。

```cangjie
package cj

import interoplib.interop.*

public interface Valuable {
    public func value(): Int
}

public open class Singleton <: Valuable {
    private let _v: Int
    public init (v: Int) { _v = v }
    public func value(): Int { _v }
}

public class Zero <: Singleton {
    public init() { super(0) }
}
```

```java
// Valuable.java
package cj;

// Glue code imports

public interface Valuable {
    public long value();
}

// Glue code
```

```java
// Singleton.java
package cj;

// Glue code imports

public class Singleton implements Valuable {
    // Glue code

    public Singleton(long v) {
        // Glue code that constructs an instance of the Cangjie Singleton class
        // and associates it with the  Java  object 'this'
    }

    public long value() {
        // Glue code that retrieves the associated Cangjie Singleton class
        // instance, calls its member function value() and returns the result
    }

    // Glue code
}
```

```java
package cj;

// Glue code imports

public final class Zero extends Singleton {
    // Glue code

    public Zero() {
        // Glue code that constructs an instance of the Cangjie Zero class
        // and associates it with the  Java  object 'this'
    }

    // Glue code
}
```

当前版本中，被镜像的类型的名称及其成员的名称，即便与 Java 关键字（例如`byte`）冲突，也将得以保留。

**成员函数**将被镜像为方法，其方法名与仓颉成员函数名保持一致，其形参类型和返回类型均被替换为相应镜像类型。返回类型为`Unit`的成员函数将被镜像为返回类型为`void`的方法。非`open`成员函数将被镜像为`final`方法。`public`和`protected`可见性修饰符将被直接保留（因为仓颉和 Java 的这两个可见性修饰符同名）。实例成员函数将被镜像为实例方法，静态成员函数则被镜像为静态方法。

> **注意：**
>
> 仓颉`interface`的静态成员函数将被镜像为实例方法。实现了该`interface`的仓颉`class`的镜像类型的胶水层代码当前存尚在问题。

**成员属性**的`getter`和`setter`（若有）将被镜像为方法。`getter`镜像得到的方法的名称由`get`开头，`setter`镜像得到的方法的名称由`set`开头，之后跟随该成员属性名称，其首字母自动大写，以保证 Java 大驼峰命名规范。`getter`镜像得到的方法无参，返回类型为成员属性类型的镜像类型。`setter`镜像得到的方法有且仅有一个形参，形参类型为成员属性类型的镜像类型，返回类型为`void`。`public`和`protected`可见性修饰符将被直接保留（因为仓颉和 Java 的这两个可见性修饰符同名）。实例成员属性将被镜像为实例方法，静态成员属性则被镜像为静态方法。

**构造函数**将被镜像为构造方法，其形参类型均被替换为相应镜像类型。由于未定义构造函数而隐式定义的构造函数同样也会被镜像。`public`可见性修饰符将被直接保留（因为仓颉和 Java 的这个可见性修饰符同名）。各形参名均将保持一致。

总体来说只有以下实体将被镜像：

* 上述列举的`public`构造函数和成员。
* `open`类中可见性为`protected`的`open`成员，包括`protected`的抽象成员函数，因为需要支持在 Java 侧对这类成员进行重写。

**成员变量**和**操作符重载函数**当前不会被镜像。

与 Java 不同，仓颉不支持类型嵌套定义，故仓颉类型的镜像类型定义中，胶水代码可能会定义`private`的嵌套类型，但镜像类型一定不会对外暴露任何嵌套类型。

当前版本对可被镜像的`class`和`interface`类型施加了诸多严格限制，可以说需要专门为 Java 互操作量身定制：

* `abstract class`不会被镜像。

* 成员变量不会被镜像，故 Java 侧不存在任何直接访问之的途径。该限制将在未来版本中移除，不过当前开发者可以通过在仓颉侧定义相应的`getter/setter`成员函数作为临时解决方案。

* 支持通过单态化为泛型`class`类型生成镜像，详情请参见[仓颉泛型](#仓颉泛型)章节。

* 不支持被镜像的`class`或`interface`中包含操作符重载函数，否则将导致编译报错。

* 被镜像的`class`或`interface`中，如果被镜像的成员或构造函数的形参类型或返回类型中存在不支持的类型，将导致编译报错。

### 仓颉`enum`类型

仓颉`enum`类型将被镜像为 Java 侧无任何`public`构造方法的`final class`。

```cangjie
public enum TimeUnit {
    | Year(Int64)
    | Month(Int64)
    | Year
    | Month
}
```

```java
public final class TimeUnit {
    /* 胶水代码 */

    public static TimeUnit Year(long p1) {
         // Glue code creating a Cangjie Year(p1) enum and associating it
         // with a newly created  Java  TimeUnit instance
    }

    public static TimeUnit Month(long p1) {
         // Glue code creating a Cangjie Month(p1) enum and associating it
         // with a newly created  Java  TimeUnit instance
    }

    public static TimeUnit Year =
        // Glue code creating a Cangjie Year enum and associating it
        // with a newly created  Java  TimeUnit instance

    public static TimeUnit Month =
        // Glue code creating a Cangjie Year enum and associating it
        // with a newly created  Java  TimeUnit instance

    /* 其他胶水代码 */
}
```

**无参构造器**将被镜像为静态字段，字段名与构造器名称保持一致，初始值为调用仓颉`enum`相应构造器的胶水代码。

**有参构造器**将被镜像为静态方法，方法名与构造器名称保持一致，形参类型均被替换为相应镜像类型，形参名称自动生成（`p1`、`p2`等）。

**成员函数**将被镜像为方法，其方法名与仓颉成员函数名保持一致，其形参类型和返回类型均被替换为相应镜像类型。返回类型为`Unit`的成员函数将被镜像为返回类型为`void`的方法。`public`可见性修饰符将被直接保留（因为仓颉和 Java 的这个可见性修饰符同名）。实例成员函数将被镜像为实例方法，静态成员函数则被镜像为静态方法。

**成员属性**的`getter`（`enum`禁止拥有`mut`成员属性）将被镜像为方法。`getter`镜像得到的方法的名称由`get`开头，之后跟随该成员属性名称，其首字母自动大写，以保证 Java 大驼峰命名规范。`getter`镜像得到的方法无参，返回类型为成员属性类型的镜像类型。`public`可见性修饰符将被直接保留（因为仓颉和 Java 的这个可见性修饰符同名）。实例成员属性将被镜像为实例方法，静态成员属性则被镜像为静态方法。

当前版本对可被镜像的`enum`类型施加了以下若干限制：

* 不支持被镜像的`enum`实现有除`Any`外的任何`interface`，否则将导致编译报错。

* 支持通过单态化为泛型`enum`类型生成镜像，详情请参见[仓颉泛型](#仓颉泛型)章节。

* 不支持被镜像的`enum`中包含操作符重载函数，否则将导致编译报错。

* 被镜像的`enum`中，如果被镜像的构造器或成员中存在不支持的类型，将导致编译报错。

当前，通过`extend`为`enum`定义的成员会被视作`enum`原本定义的一部分来进行镜像。

递归定义的`enum`类型同样也是支持的：

```cangjie
public enum Peano {
    | Z
    | S(Peano)

    public func toInt(): Int {
        match (this) {
            case Z => 0
            case S(x) => 1 + x.toInt()
        }
    }
}
```

### 仓颉泛型

 Java 和仓颉的泛型存在本质性的差异，使得仓颉泛型无法被镜像为 Java 泛型。然而，仓颉泛型的具体实例化后的类型（例如`G<Int64>`）是具体类型，而具体类型则可以被镜像为非泛型的 Java 类型。像这样的具体类型被称为单态化了的泛型类型。

> **注意：**
>
> 当前版本存在以下限制：
>
> * 当前能用于单态化泛型类型的类型实参仅支持基本数据类型。
>
> * 禁止被镜像的成员函数拥有自己的类型形参。

开发者可以通过在[配置文件](#仓颉镜像生成配置)中指定需要为哪些泛型类型的哪些实例化的具体类型生成镜像，详情请参见[泛型实例化](#为泛型仓颉类型进行镜像)。

**例子:**

用 cjc 编译以下仓颉泛型`class`时：

```cangjie
public class G<T> {
    private let t: T
    public init(t: T) { this.t = t }
    public func get(): T { t }
}
```

在配置文件相应`[[packages]]`配置块中添加以下内容：

```toml
       .  .  .
    generic_object_configuration  = [
        { name = "G", type_arguments = ["Bool", "Int"] },
    ]
       .  .  .
```

 cjc 将分别为`G<Bool>`和`G<Int>`生成相应镜像类型，并分别命名为`GBool`和`GInt`。

上述的完整操作说明请参见[仓颉镜像生成参考](#仓颉镜像生成参考)。

### 仓颉侧`null`值处理

由于仓颉侧没有`null`值的概念，任何从 Java 侧传到仓颉侧的`null`值都将导致从仓颉侧抛出`NullPointerException`异常。

```cangjie
public class Node {
    private let next: ?Node
    public init() {
        next = None
    }
    public init(next: Node) {      /* Pure Cangjie */
        this.next = Some(next)
    }
}
```

```java
public final class Node {
    Node() { /* 胶水代码 */ }
    Node(Node next) { /* 胶水代码 */ }
}
   .  .  .
     Node list = new Node(null);   /* 此处调用将抛出 NullPointerException 异常 */
```

反过来，无法通过返回类型为 Java 兼容类型的`public`成员函数从仓颉侧返回`null`值到 Java 侧。

> **注意：**
>
> 当前版本支持自动的`Option<T>`装/拆包，`null`值被映射为`None`，但该装/拆包仅支持由 Java 引用类型镜像而来的仓颉类型，而反过来仓颉自定义类型则不支持。详情请参见[Java 侧`null`值处理](#java-null值处理)。

## 仓颉镜像生成参考

仓颉 SDK 中提供了专门为 Java 类型生成镜像类型的独立工具`java-mirror-gen.jar`，也提供了专门为 Objective-C 类型生成镜像类型的独立工具`ObjCInteropGen`，而为仓颉类型生成镜像类型的职责则直接由 cjc 所承担：cjc 能够在编译仓颉源码的同时为仓颉类型生成镜像类型。

### 命令行选项参考

以下若干 cjc 编译选项将使能并控制如何在编译期为仓颉类型生成镜像类型：

`--experimental`    _(必选)_

当前版本下，该编译选项必须指定，因为整个跨平台互操作特性尚在开发中，待开发完毕后则将不再需要。

`--enable-interop-cjmapping=Java` _或_
`--enable-interop-cjmapping=ObjC`        _(必选)_

该编译选项将使能 cjc 为仓颉类型生成镜像类型，当值为` Java `时，生成的是 Java 版本的镜像类型；当值为`ObjC`时，则生成的是 Objective-C 版本的镜像类型。

`--output-interop-cjmapping-dir` _`pathname`_     _(可选)_

该编译选项指定了一个目录， cjc 将把生成的包含镜像类型定义（ Java 或 Objective-C 源码）的源文件放置在该目录下。如果`pathname`所对应的路径尚不存在，cjc 将创建该目录；如果`pathname`路径已存在，且并非目录，cjc 则将不进行镜像类型生成并报错。

该编译选项可选，如果未指定，则默认为`./java-gen`或`./objc-gen`，取决于`--enable-interop-cjmapping`选项值为` Java `或`ObjC`。

`--import-interop-cj-package-config-path` _`pathname`_     _(可选)_

该编译选项指定了所采用的用于控制镜像生成的配置文件的路径，有关配置文件详情请参见[仓颉镜像生成配置](#仓颉镜像生成配置)章节。

### 仓颉镜像生成配置

仓颉镜像生成配置文件是符合 TOML 语法的纯文本文件，其中指定了：

* 需要为哪些非泛型仓颉类型生成镜像类型
* 需要为哪些泛型仓颉类型进行单态化以生成相应非泛型的镜像类型

#### 默认配置

在`[default]`表下可以指定默认配置。仓颉镜像生成的操作单元是仓颉包，如果某仓颉包相应的[单包配置](#单包配置)表中未指定某配置值，则该配置将默认采用[默认配置](#默认配置)中相应的值；如果在[默认配置](#默认配置)中也没有指定该配置项，则将采用该配置项的默认值。

在默认配置中可以设置以下配置项：

`APIStrategy`    _(可选)_

该配置项的值为字符串，决定是否为所有`public`实体生成镜像。该配置项的有效值为：

* `"Full"` _(默认)_ - 只为不被列举在`excluded_apis`黑名单中的所有`public`实体生成镜像
* `"None"` - 只为列举在`included_apis`白名单中的所有`public`实体生成镜像

`GenericTypeStrategy`    _(可选)_

该配置项的值为字符串，决定是否为泛型实体生成镜像。该配置项的有效值为：

* `"Partial"` - 根据`generic_object_configuration`配置项为泛型实体生成镜像
* `"None"` _(默认)_ - 所有泛型实体均不为其生成镜像

#### 单包配置

在`[[packages]]`中进行单包配置，首先指定一个包名，接下来该表中的所有配置项均仅对该包生效。该配置块中支持以下配置项：

* 控制 cjc 为哪些仓颉类型生成或不生成镜像类型的白名单或黑名单。
* 针对单包的镜像生成策略（如果需要有别于[默认配置](#默认配置)）。
* 针对单包的泛型类型镜像生成策略（如果需要有别于[默认配置](#默认配置)）。
* 指定需要为哪些泛型类型单态化为哪些具体类型。

该配置块支持以下配置项：

`name`    _(必选)_

该配置项的值为字符串形式的包名，说明其所在`[[packages]]`配置块对哪个仓颉包单独生效，例如：

```toml
[[packages]]
name = "com.example.VectorMath"
```

`APIStrategy`    _(可选)_

该配置项的值为字符串，决定是否为所有`public`实体生成镜像。该配置项的有效值为：

* `"Full"` - 只为不被列举在`excluded_apis`黑名单中的所有`public`实体生成镜像
* `"None"` - 只为列举在`included_apis`白名单中的所有`public`实体生成镜像

该配置项无默认值，如果该配置项未被指定，[默认配置](#默认配置)中的相应配置项将被采用。

`included_apis`    _(可选)_

该配置项的值为字符串数组，数组中每字符串是一个希望被生成镜像的`public`实体的名称。如果一个类型的限定名称被包含在这个数组中，那么该类型也会被生成镜像。例如：

```toml
included_apis = [
   "Vector.product", // 此处 Vector 类型没有被单独指定，但依然会为 Vector 类型其生成镜像
   "HiddenV"
]
```

`excluded_apis`    _(可选)_

该配置项的值为字符串数组，数组中每字符串是一个**不**希望被生成镜像的`public`实体的名称。例如：

```toml
excluded_apis = [
   "Vector.product", // 即便 Vector 类型将被生成镜像，但 product 成员却依然不会被生成镜像
   "HiddenV"
]
```

> **注意：**
>
> `excluded_apis`和`included_apis`两个配置项之间互斥，在一个`[[packages]]`表中不能被同时指定。换句话说，在一个`[[packages]]`配置块中，当`APIStrategy`为`Full`时，默认为所有`public`实体生成镜像，进而可以通过配置`excluded_apis`黑名单来排除其中不需要为其生成镜像的实体，但禁止配置`included_apis`；当`APIStrategy`为`None`时，默认不为任何`public`实体生成镜像，进而可以通过配置`included_apis`白名单来选定需要为哪些实体生成镜像，但禁止配置`excluded_apis`。

`GenericTypeStrategy`    _(可选)_

该配置项的值为字符串，决定是否为泛型实体生成镜像。该配置项的有效值为：

* `"Partial"` - 根据`generic_object_configuration`配置项为泛型实体生成镜像
* `"None"` _(默认)_ - 所有泛型实体均不为其生成镜像

该配置项无默认值，如果该配置项未被指定，[默认配置](#默认配置)中的相应配置项将被采用。

`lambda_patterns`    _(可选)_

该配置项的值为一个数组，数组元素是表，每个表描述了一个函数类型。这些被描述的函数类型都是被镜像的实体所用到的，于是镜像类型中一定也会用到这些函数类型的镜像类型，故这些函数类型本身也必须被生成镜像。如果在镜像生成过程中发现存在未被指定在`lambda_patterns`中的函数类型，则将导致编译报错。

用于描述一个函数类型的表包含以下若干属性：

`signature`    _(必选)_

该属性值为字符串，包含一个仓颉函数签名，例如`(Int) -> Int`。

示例：

```toml
lambda_patterns = [
    { signature = "(Int) -> Int" },
    { signature = "(Float64, Float64) -> Float64" }
]
```

详情请参见[仓颉函数类型](#仓颉函数类型)章节。

`tuple_configuration`    _(可选)_

该配置项的值为一个数组，数组元素是表，每个表描述了一个元组类型。这些被描述的元组类型都是被镜像的实体所用到的，于是镜像类型中一定也会用到这些元组类型的镜像类型，故这些元组类型本身也必须被生成镜像。如果在镜像生成过程中发现存在未被指定在`tuple_configuration`中的元组类型，则将导致编译报错。

示例：

```toml
tuple_configuration = [
    "(Int, Bool)",
    "(Float64, Float64, Float64)"
]
```

详情请参见[仓颉元组](#仓颉元组类型)章节。

`generic_object_configuration`    _(可选)_

该配置项的值是一个数组，数组中的每一个元素是一个表，每个表指定了针对一个泛型类型，需要为其生成哪些具体类型的镜像类型。一个表中包含以下属性：

`name`

该属性是一个`public`类型的简单名称，该类型需定义在名为其所在`[[packages]]`的`name`的包中。

`type_arguments`

该属性是一个字符串数组，每个字符串是一个**有效的**类型实参列表。

> **注意：**
>
> 当前版本仅支持`Unit`、`Bool`和数值类型作为此处用于泛型单态化的类型实参，如果用到了任何不支持的类型将导致编译报错。

上述中所谓“有效的”类型实参列表，简单来说，就是要求相应的泛型类型理论上能够使用该类型实参列表进行实例化。

请考虑以下代码片段：

```cangjie
public class G<T> {
    public func f(t: T): Unit {}
    public func f(b: Bool): Unit {}
}
```

`G<Bool>`理论上无法被实例化（否则将导致存在两个完全一样的成员函数），于是以下配置将导致编译报错：

```toml
generic_object_configuration  = [
    { name = "G", types = ["Bool"] }
]
```

使用示例：

1. 假设存在以下仓颉类型定义：

    ```cangjie
    public class G<T> { /* ... */ }
    public func f<T>(): Unit { /* ... */ }
    public struct S<T, U> { /* ... */ }
    ```

    以及以下配置：

    ```toml
    generic_object_configuration  = [
        { name = "G", type_arguments = ["Int"] },
        { name = "f", type_arguments = ["Int", "Bool"] },
        { name = "S", type_arguments = ["Int, Bool"] }
    ]
    ```

     cjc 根据该配置将为以下单态化了的泛型类型生成镜像类型：

    ```cangjie
    G<Int> // 镜像类型名为 GInt
    f<Int> // 镜像类型名为 fInt
    f<Bool> // 镜像类型名为 fBool
    S<Int, Bool> // 镜像类型名为 SIntBool
    ```

2. 假设存在以下仓颉源文件：

    ```cangjie
    package cjworld

    import interoplib.interop.*

    public class Composer<T, U, V> {
        public static func compose(f: (T) -> U, g: (U) -> V): (T) -> V {
            { t: T => g(f(t)) }
        }
    }
    ```

    以及以下[配置文件](#仓颉镜像生成配置)：

    ```toml
    [[package]]
    name = "cjworld"
    APIStrategy = "Full"
    GenericTypeStrategy = "Partial"

    lambda_patterns = [
        { signature = "(Int) -> Float64" },
        { signature = "(Float64) -> Bool" }
    ]

    generic_object_configuration = [
        { name = "Composer", type_arguments = ["Int64, Float64, Bool"] },
        { name = "Composer<Int64, Float64, Bool>", symbols = ["compose"] },
    ]
    ```

     cjc 根据该配置文件将生成以下非泛型的镜像类型：

    * Java 函数式接口`Int64ToFloat64`：

        ```java
        // ...
        @FunctionalInterface
        public interface Int64ToFloat64 {
            public double call(long p1);
            // ...
        }
        ```

    * Java 函数式接口`Float64ToBool`：

        ```java
        /* ... */
        @FunctionalInterface
        public interface Float64ToBool {
            public boolean call(double p1);
            /* ... */
        }
        ```

    * Java 类`ComposerInt64Float64Bool`：

        ```java
        /* ... */
        public class ComposerInt64Float64Bool {
            /* ... */
            public static Int64ToBool compose(Int64ToFloat64 f, Float64ToBool g) {
                /* ... */
            }
            /* ... */
        }
        ```

## 在仓颉侧使用 Java

在第一种使用场景中，仓颉侧定义的类型被镜像后，在 Java 侧可以完全自然地使用，例如对非`final`的`class`进行`extends`，`implements`仓颉镜像`interface`，实例化并作为入参四处传递等，详细介绍请参见[在 Java 侧使用仓颉](#在-java-侧使用仓颉)。

然而相比之下，由于安卓运行时环境（JVM）的技术限制，如果想在仓颉侧使用 Java 的类型，就必须将仓颉的代码逻辑完全限制在仓颉[互操作类](#互操作类)的构造函数和成员函数内部。另外，与由 cjc 编译仓颉源码为仓颉类型生成 Java 侧可用的镜像类型不同， CJMP 提供了一个[独立工具](#java-镜像生成器参考)来为 Java 类型生成仓颉侧可用的镜像类型。

因此，第二种使用场景的具体操作步骤相较于第一种使用场景来说更为复杂，具体如下：

1. 基于 Java 类和方法，设计互操作胶水层。
   开发者 -> 互操作胶水层设计（ Java 伪代码）

2. 根据上一步设计的胶水层，为所有现存相关的 Java 类和接口借助 Java 镜像生成器生成仓颉侧可用的`@JavaMirror`类型定义。
    `.class` - Java 镜像生成器-> `.cj`（镜像类型定义）

3. 使用仓颉编写实现互操作层，仓颉代码中按需使用`@JavaMirror`镜像类型，例如创建镜像类型的实例，调用其成员函数等。
    互操作胶水层设计 + `.cj`（镜像类型定义）-开发者-> `.cj`（胶水层实现）

4. 将`@JavaMirror`镜像类型定义和第 3 步中使用仓颉实现的互操作层一起使用 cjc 编译，编译将得到：
    * 包含互操作层逻辑的动态库。
    * 若干 Java 侧可用的镜像类型定义源文件。
    `.cj`（镜像类型定义 + 胶水层实现）- cjc -> `.so` + `.java`（胶水层镜像类型定义）

5. 将以下中间产物添加进 Android Studio 工程:
    * 第 4 步中由 cjc 编译产生的若干`.java`源文件，其中包含后续 Java 侧可能用到的互操作胶水层代码。
    * 第 4 步中由 cjc 编译得到的`.so`动态库文件，其中包含了由仓颉实现的胶水层逻辑。
    * 仓颉 SDK 中所有必要的运行时库，包括`.so`和`.jar`等。

    接着，在 Java 侧编写必要的对胶水层中提供的镜像类型的实例化和方法调用，完成后重构建工程即可。
    Android Studio 工程 + `.java` + `.jar` + `.so` -安卓工具链-> `.apk`

[从零实现胶水层](#从零实现胶水层)章节将通过一个端到端的例子来详细说明上述流程。

### 从零实现胶水层

#### 第一步：设计互操作胶水层

在这一步，开发者需要**从 Java 源码的视角**，来设计一到若干个[互操作类](#互操作类)。互操作类由仓颉编写实现，但最终会由 cjc 编译生成镜像类以便 Java 侧使用，因此在 Java 侧看来，并不关心互操作类的具体实现，而只需要关心 Java 侧需要哪些功能。因此，对每个[互操作类](#互操作类)，开发者只需要考虑以下要点：

* 互操作类应该放在哪个 Java 包中？
* 互操作类是默认继承`java.lang.Object`，还是需要继承其他 Java 类？
* 互操作类是否需要实现任何 Java 接口？
* 互操作类中需要拥有哪些`public`/`protected`构造方法/成员方法？开发者目前只需要知道它们的功能以确定其函数签名，真正的实现则是在后续步骤中通过仓颉编写。

另请参见[互操作类的特性与限制](#互操作类的特性与限制)。

**例子：**

假设，开发者希望在 Java 侧通过调用一个静态方法来将控制流从 Java 侧切换到仓颉侧，这个静态方法的名称为`m`，接收 3 个形参，形参类型分别为`com.example.a.A`、`java.lang.String`和`int`，并返回类型为`com.example.b.B`的值。开发者还希望这个静态方法属于一个叫做`Interop`的类，且该类位于名为`cjworld`的 Java 包中，不继承任何 Java 类，也就是说，默认继承`java.lang.Object`，也不实现任何接口。

根据上述描述，事实上已经确定了，未来在步骤四中通过 cjc 为互操作类生成的镜像类型定义的骨架如下：

```java
// Java 包名为`cjworld`
package cjworld;

// 为定义静态方法`m`，需要依赖以下两个其他包中定义的类型
import com.example.a.A;
import com.example.b.B;

// 互操作类在 Java 侧的镜像类型定义
public class Interop {
    /* 胶水代码 */
    public static B m(A a, String s, int i) {
        /* 调用仓颉侧静态成员函数`m`实现逻辑的胶水代码 */
    }
    /* 其他胶水代码 */
}
```

#### 第二步：生成镜像类型声明

现在，切换到仓颉侧源码的视角，开发者需要获得在仓颉侧编写互操作类所依赖的所有 Java 类型的镜像类型，根据上一步可知具体依赖哪些 Java 类型：互操作类的父类型、形参类型、返回类型，甚至可能还有这些类型本身所依赖的类型。

> **注意：**
>
> CJMP 互操作库中预置了`java.lang.Object`、`java.lang.String`和泛型 Java 数组类型的镜像类型，而 Java 基本数据类型也无需镜像，在仓颉侧使用对应的仓颉基本数据类型即可。如果开发者的互操作类中并没有用到除了前述这几种类型外的其他 Java 类型，那么实际上可以直接跳过步骤二。

以下说明了如何使用[Java 镜像生成器](#java-镜像生成器参考)来为依赖的 Java 类型生成镜像类型：

```bash
java-mirror-gen \
    --package-name <package-name> \
    --class-path <full-application-classpath> \
    --destination <output-directory> \
    <names-of-mirrored-types>
```

或者这样，指定 JAR 包：

```bash
/path/to/jdk/21/bin/java \
java-mirror-gen \
    --package-name <package-name> \
    --class-path <full-application-classpath> \
    --destination <output-directory> \
    -jar <jar-file>
```

在上述命令中：

* `<package-name>` 指定了为 Java 类型生成的镜像类型希望的包名。之所以镜像类型的包名不一定能与原 Java 类型的报名保持一致，与[循环导入依赖](#处理循环导入依赖)有关。

* `<full-application-classpath>`指定了本次镜像生成所采用的类路径，包括安卓 SDK 的`android.jar`，和安卓项目构建得到的`App.jar`等，类路径之间由冒号分隔。

* `<output directory>` 指定了生成的包含镜像类型的仓颉源文件希望被放置在哪个目录下，例如`./src/cj`。

* `<names-of-mirrored-types>`是一到多个 Java 引用类型的完全限定名，之间以空格分隔。这些类型是在互操作类设计过程中开发者所识别出来的除了`java.lang.Object`、`java.lang.String`和 Java 数组类型外的其他 Java 引用类型，`java-mirror-gen`将为这些类型生成镜像。

* `<jar-file>`是单个`jar`文件的路径，这个`jar`中的所有`.class`文件中的`public`的`class`和`interface`均将被生成镜像，且这些类型所依赖的类型（在`<full-application-classpath>`的类路径下找到）也会被生成镜像。

**例子:**

延续之前的例子，开发者注意到将定义的互操作类`cjworld.Interop`依赖如下类型：

* 父类型`java.lang.Object`
* 静态成员函数`m`的形参类型`com.example.a.A`、`java.lang.String`和`int`
* 静态成员函数`m`的返回类型`com.example.b.B`

对于上述类型，开发者并不需要为 Java 基本数据类型`int`生成镜像类型，而`java.lang.Object`和`java.lang.String`这两个 Java 类型的镜像类型则在 CJMP 互操作库中预置了。所以事实上开发者只需要为`com.example.a.A`和`com.example.b.B`这两个 Java 类型生成镜像类型即可。假设我们希望将生成的镜像类型放在名为`javaworld`的仓颉包中，以下是一条 Java 镜像生成器的命令行调用：

```bash
java-mirror-gen \
    --package-name javaworld \
    --class-path /home/user/Android/Sdk/platforms/android-35/android.jar:App.jar \
    --destination ./src/cj \
    com.example.a.A com.example.b.B
```

上述命令将生成`src/cj/javaworld/src/A.cj`和`src/cj/javaworld/src/B.cj`两个文件，其中分别包含了两个 Java 类型的镜像类型声明。如果这两个 Java 类型还依赖其他需要生成镜像类型的 Java 类型，则会同时生成在相同目录下。

#### 第三步：实现互操作类

现在开始真正为开发者在第一步中描绘的 Java 类的骨架，使用仓颉来实现其逻辑，请参考以下要点：

1. 互操作类所在的包名和类名与步骤一中的设计保持一致（ cjc 编译互操作类自动生成的 Java 封装类的包名和类名与互操作类的包名和类名是完全一样的）。
2. 导包`java.lang.*`。
3. 导入实现互操作类所必要的镜像类型，这些镜像类型是开发者在步骤二中通过 Java 镜像生成器生成的。不过，暂时先不要导入其他依赖类型。
4. 为互操作类加上注解`@JavaImpl`。
5. 互操作类继承某 Java 类的镜像类型。被注解了`@JavaImpl`的互操作类默认继承预置在互操作库中的`java.lang.Object`的镜像类型。
6. 仓颉代码中，任何需要使用`java.lang.Object`、`java.lang.String`和 Java 数组的地方，分别使用`JObject`、`JString`和`JArray<T>`来实现相应功能逻辑。

 Java 类型到仓颉类型的映射关系：

 Java 类型 (`T`)  | 仓颉类型 (`T'`)
---------------- | -----------------------------
`boolean`        | `Bool`
`byte`           | `Int8`
`short`          | `Int16`
`char`           | `UInt16`
`int`            | `Int32`
`long`           | `Int64`
`float`          | `Float32`
`double`         | `Float64`
`Object`         | `JObject` 或 `?JObject`
`String`         | `JString` 或 `?JString`
`class C`        | `C'` 或 `?C'`
`interface I`    | `I'` 或 `?I'`
`T[]`            | `JArray<T'>` 或 `?JArray<T'>`

对于可能接收或持有`null`值的镜像类型和互操作类的形参类型、返回类型和局部变量类型，请使用`Option<T'>`，而不是`T'`。详情请参见[null 值处理](#java-null值处理)。

 Java 侧返回类型为`void`的方法，在仓颉侧的对应函数返回类型是`Unit`。

另请参见[互操作类的特性与限制](#互操作类的特性与限制)。

延续之前的例子，实现的互操作类也许类似如下：

```cangjie
package cjworld

import java.lang.*
import javaworld.*

@JavaImpl
public class Interop {
    public static func m(a: ?A, s: ?JString, i: Int32): ?B {
        /* 此处可以实现各种逻辑 */
        B()    // 假设com.example.b.B拥有一个`public`无参构造方法
    }
}
```

在上述例子中，如果静态成员函数`m`在设计上压根不可能返回`null`到 Java 侧，那么完全可以将`m`的返回类型改为`B`，互操作依然可以正常工作。

#### 第四步：编译互操作类

使用以下命令进行对互操作类实现进行编译:

```bash
 cjc  --output-type=dylib \
    -p <source-directory> \
    -ljava.lang -linteroplib.interop \
    --output-javagen-dir=<java-output-directory>
```

在上述命令中：

`<source-directory>`是保存互操作类和镜像类型声明源文件所在的目录的路径。

`<java-output-directory>`是预期存放编译过程中自动生成的 Java 源文件的目录的路径。

上述 cjc 编译命令的直接编译产物是包含了互操作类定义的`.so`仓颉动态库文件，以及若干保存 Java 包装类的 Java 源文件。

例如：

```bash
 cjc  --output-type=dylib \
    -p src/cj \
    -ljava.lang -linteroplib.interop \
    --output-javagen-dir=src/java
```

编译将生成两个文件：`libcjworld.so`和`src/java/cjworld/Interop.java`，后者包含了 Java 侧可以使用的互操作类的镜像类。

#### 第五步：整合先前步骤中的所有产物

1. 将以下文件添加至 Android Studio 工程：
    * 第四步中由 cjc 生成的所有 Java 源文件，添加至`src/main`目录下，根据其实际包名，创建必要的目录结构，将源文件放至对应目录位置。
    * 第四步中由 cjc 编译得到的`.so`文件，添加至`src/main/jniLibs/arm64-v8a`目录下，如果该子目录不存在，手动创建之即可。
    * 将`$CANGJIE_HOME/runtime/lib/linux_android_aarch64_cjnative`目录下的所有`.so`文件复制进`src/main/jniLibs/arm64-v8a`目录下。
    * 将安卓 NDK 中的`libc++_shared.so`文件复制进`src/main/jniLibs/arm64-v8a`目录下。该文件位于安卓 NDK 根目录下的`toolchains/llvm/prebuilt/<host>/sysroot/usr/lib/aarch64-linux-android`目录下，其中`<host>`是开发者构建安卓工程所在的平台的`${os}-${arch}`组合，例如，如果是在 x64 架构 Linux 上构建安卓工程，则`<host>`为`linux-x86_64`。
    * 将`$CANGJIE_HOME/lib/library-loader.jar`作为安卓工程的 JAR 包依赖。

2. 重要提示：必须强制使用传统规范，将所有`APK`中的`.so`文件进行压缩，否则应用运行时，将在尝试加载仓颉库的时候发生崩溃。请找到安卓工程中的 Gradle 构建脚本（一般名为`build.gradle.kts`），在其中找到`android {}`配置块，检查配置块中是否已经存在以下配置信息。如果没有，请将以下配置信息插入其中：

   ```java
      .  .  .
   android {
          .  .  .
       packaging {
           jniLibs {
               useLegacyPackaging = true
           }
       }
   }
      .  .  .
   ```

3. 请重新构建安卓工程，确保截至目前安卓工程能够成功构建，不存在任何问题。构建成功后，也可以尝试推送安装应用检查是否安装上存在任何问题。

4. 现在开发者就可以在 Java 源码中编写原先预想的调用互操作类的代码逻辑了。编写完成后，再次重新构建安卓工程。

延续之前的例子，在 Java 侧，现在开发者就可以编写逻辑调用`Interop.m`方法了，调用这个方法就会使得程序控制交给仓颉侧的互操作类的实现逻辑：

```java
       .  .  .
    B b = Interop.m(new A(), "Test", 0);
       .  .  .
```

### 仓颉侧调用 Java

现在开发者已经设计了胶水层，实现并构建了互操作类，将各个必要的产物集成进了安卓工程，接下来，可以继续往仓颉侧的互操作类中加入更多的代码逻辑。类型映射关系与[在仓颉侧使用 Java](#在仓颉侧使用-java)实际上是一模一样的。

仓颉类型 (`T'`)           |  Java 类型 (`T`) | 备注
----------------------------- | --------------- | ------
`Bool`                        | `boolean`       | -
`Int8`                        | `byte`          | -
`Int16`                       | `short`         | -
`UInt16`                      | `char`          | -
`Int32`                       | `int`           | -
`Int64`                       | `long`          | -
`Float32`                     | `float`         | -
`Float64`                     | `double`        | -
`JObject`或`?JObject`       | `Object`        | -
`JString`或`?JString`       | `String`        | -
`T'`或`?T'`                 | `T`             | (\*)
`JArray<T'>`或`?JArray<T'>` | `T[]`           | (\*\*)

**(\*)** `T'`必须要么是互操作类，要么是 Java 类型`T`的镜像类型。如果`T'`是互操作类，`T`则是 Java 侧的一个包装类，且该包装类是由 cjc 在编译互操作类`T'`时自动生成的。

**(\*\*)** `T'`必须要么是互操作类，要么是镜像类型，要么是上表中列举的值类型。

仓颉侧调用返回类型为`void`的 Java 方法的返回值类型为`Unit`。

限制：不支持 Java 方法的变长形参列表。

#### 步骤零: 正常构建安卓工程

#### 步骤一: 为仓颉侧生成 Java 类型的镜像类型声明

如果开发者在互操作类的内部实现中，只会调用互操作类中的成员函数，那么由于这些成员函数的函数签名中的所有 Java 类型均已生成镜像类型，理论上可以直接跳过这步，无需使用 Java 镜像生成器生成更多的镜像类型。

使用 Java 镜像生成器为 Java 类型生成镜像类型的命令行：

```bash
java-mirror-gen \
    --package-name <package-name> \
    --class-path <full-application-classpath> \
    --destination <output-directory> \
    <names-of-mirrored-types>
```

或：

```bash
/path/to/jdk/21/bin/java \
java-mirror-gen \
    --package-name <package-name> \
    --class-path <full-application-classpath> \
    --destination <output-directory> \
    -jar <jar-file>
```

在上述命令中：

* `<package-name>` 指定了为 Java 类型生成的镜像类型希望的包名。之所以镜像类型的包名不一定能与原 Java 类型的报名保持一致，与[循环导入依赖](#处理循环导入依赖)有关。

* `<full-application-classpath>`指定了本次镜像生成所采用的类路径，包括安卓 SDK 的`android.jar`，和安卓项目构建得到的`App.jar`等，类路径之间由冒号分隔。

* `<output directory>` 指定了生成的包含镜像类型的仓颉源文件希望被放置在哪个目录下，例如`./src/cj`。

* `<names-of-mirrored-types>`是一到多个 Java 引用类型的完全限定名，之间以空格分隔。这些类型是在互操作类设计过程中开发者所识别出来的除了`java.lang.Object`、`java.lang.String`和 Java 数组类型外的其他 Java 引用类型，`java-mirror-gen`将为这些类型生成镜像。

* `<jar-file>`是单个`jar`文件的路径，这个`jar`中的所有`.class`文件中的`public`的`class`和`interface`均将被生成镜像，且这些类型所依赖的类型（在`<full-application-classpath>`的类路径下找到）也会被生成镜像。

延续之前的例子，假设开发者希望在仓颉侧的`Interop.m`静态成员函数中，调用 Java 侧定义的`com.example.c.C`的签名为`String g(A a, int i)`静态方法，其定义如下：

```java
package com.example.c;

import com.example.a.A;

public class C {
    public static String g(A a, int i) {
        /* Some  Java  code returning a string */
    }
}
```

由于`com.example.c.C`是新引入的互操作类中用到的类型，尚不存在其镜像类型供互操作类使用，故需要重新执行 Java 镜像生成器命令。这次额外新增一个入参`com.example.c.C`，其他则保持不变：

```bash
java-mirror-gen \
    --package-name javaworld \
    --class-path /home/user/Android/Sdk/platforms/android-35/android.jar:App.jar \
    --destination ./src/cj \
    com.example.a.A com.example.b.B com.example.c.C
```

这条命令所生成的所有镜像类型声明文件，是在之前的基础上，新增一个`src/javaworld/src/C.cj`，并且如果`com.example.c.C`类型本身依赖其他需要生成镜像类型的 Java 类型，且这些类型尚未被镜像，那么也会同时生成这些类型的镜像类型声明文件。

新生成的文件`src/cj/javaworld/src/C.cj`的内容如下：

```cangjie
package javaworld

import java.lang.*

@JavaMirror["com.example.c.C"]
public class C {
    public static func g(a: ?A, i: Int32): ?JString
}
```

#### 步骤二：导入镜像类型并实现互操作类的逻辑

确保用于实现互操作类的所有镜像类型均已生成，并导入它们，接着就可以把它们完全当成仓颉类型来使用，实现互操作类中构造函数和成员函数的逻辑了。

延续之前的例子，这时开发者就可以在`cjworld.Interop.m`函数体中使用`javaworld.C`了：

```cangjie
package cjworld

import java.lang.*
import javaworld.A
import javaworld.B
// 新增导入
import javaworld.C

@JavaImpl
public class Interop {
    public static func m(a: ?A, s: ?JString, i: Int32): ?B {
        let s1: JString = match (a) {
            case Some(aa) => C.g(aa, i) ?? JString("")
            case None => JString("")
        }
        B(s1)  // 假设B存在一个签名为`B(String)`的构造方法
    }
}
```

#### 步骤三：重编仓颉部分的源码

详情请参见[从零实现胶水层](#从零实现胶水层)中的[步骤四](#第四步编译互操作类)。

#### 步骤四：更新并重新构建安卓工程

只要开发者确定在前几步中没有改变互操作类所暴露的`public`接口的签名，那么理论上只需要在重编仓颉实现源码后更新安卓工程中的`.so`文件。只要互操作类所暴露的`public`接口签名保持不变， cjc 所生成的 Java 胶水层源码内容理论上是完全一致的。

将步骤三中新生成或更新了的`.so`文件和`.java`文件（如有必要）更新到安卓工程的对应位置，然后重新构建安卓工程。

详情请参见[从零实现胶水层](#从零实现胶水层)中的[步骤五](#第五步整合先前步骤中的所有产物)。

### 互操作类的特性与限制

1. 互操作类必须是`@JavaMirror class`的直接子类。互操作类当不显式指定继承哪个父类时，将默认继承互操作库中的[`java.lang.JObject`](#javalangjobject)，而非`std.core.Object`。

2. 互操作类可能实现一到若干个`@JavaMirror interface`，但禁止实现任何普通仓颉`interface`。反过来，普通仓颉类型禁止实现或继承`@JavaMirror interface`。

3. 互操作类禁止被声明为`open`或`abstract`，且禁止被`extend`，否则均将导致编译报错。

4. 互操作类中允许定义实例成员变量，且变量类型可以是任何仓颉类型。互操作类中允许重写其父类中的成员函数。

5. 互操作类的构造函数体中可以通过`super()`调用父类的构造函数，其对调用实例成员函数的先后顺序的规格限制，与普通仓颉构造函数的是完全一致的。另外，构造函数体中同样也需要为所有互操作类新定义的实例成员变量进行初始化，否则将导致编译报错。

6. 在互操作类的实例成员函数中，可以调用父类的实例成员函数，即便该父类中的实例成员函数被互操作类重写，也可以通过`super.`来调用之。

7. 所有镜像类型和互操作类中的构造函数和成员函数的函数签名中所用到的类型，只允许是(a)镜像类型或互操作类或(b)100%对应于 Java 基本数据类型。详情请参见[仓颉侧调用 Java](#仓颉侧调用-java)章节。

8. 镜像类型和互操作类的实例必须遵循以下规则：
    * 禁止让其逃逸到仓颉全局变量或静态成员变量，也禁止让其逃逸到此两类变量所引用的任何数据结构中。目前 cjc 尚未对此施加编译报错，因此需要用户自保障这条规则，否则可能导致程序执行过程中异常终止。

    * 当不再需要时，必须被显式释放。最好是在有释放机会时第一时间释放之，但无论如何在控制返回 JVM 前必须完成释放，否则可能导致内存泄漏，JVM 抛出`OutOfMemoryError`异常。

以下 3 条限制是安卓/JVM 特有的：

1. 任何使用了镜像类型或互操作类的仓颉代码，必须在 Java 虚拟机注册的线程中执行。该线程可由 Java 代码创建，也可以通过 Java 调用 API 注册至 JVM 的操作系统线程。在当前版本中只能通过编程规范要求遵守，未来 cjc 可能强制执行该规则。

2. 所有镜像类型和互操作类型所对应的 Java 类型，都必须由同一个类加载器所加载。

3. 与 Java 及其他 JVM 语言不同，仓颉禁止包之间存在循环导入依赖关系。该限制给镜像生成的流程带来了挑战，详情请参见[处理循环导入依赖](#处理循环导入依赖)章节。

## 由 Java 到仓颉的映射关系

当前版本的 Java 镜像生成器遵循以下所描述的 Java 到仓颉的类型映射规格。

### 一般注意事项

 Java 镜像生成器的直接输入是 Java 的`.class`文件而不是`.java`源文件，因此任何`javac`没有从 Java 源代码传播到类文件的信息，都无法被 Java 镜像生成器感知。正是由于这个原因，部分映射规则受到影响，其中最主要的是对[Java 泛型](#java-泛型)和方法形参名称的处理。

### Java 名称

 Java 类型、字段及方法的原名称会被尽可能地保留，但如果原名称由于下述的任何原因无法保留，原名称将通过`@JavaMirror`注解传播到仓颉侧，供 cjc 还原出原 Java 名称：

* 与仓颉关键字冲突的 Java 标识符，如`func`、`main`、`Int32`等，将会由反引号` `` `包裹以作为仓颉标识符，例如：

    ```java
    public static final long Int32 = 0xffff_ffff;
    ```

    ```cangjie
    public static let `Int32`: Int64
    ```

* Java 标识符中可能包含仓颉标识符所禁止的字符，最典型的就是`$`符号，其一般被用作嵌套 Java 类型在`.class`文件中二进制形式的类型名。这类字符将被替换为下划线`_`，例如：

    ```java
    public class Outer {
        public class Inner {}
        public Inner getInner() { return new Inner(); }
    }
    ```

    ```cangjie
    @JavaMirror["Outer"]
    public open class Outer {
        public init()

        public open func getInner(): ?Outer_Inner
    }

    @JavaMirror["Outer$Inner"]
    public open class Outer_Inner {
        public init(p0: ?Outer)
    }
    ```

* Java 用户自定义类型中字段、成员类型和方法允许拥有相同的标识符。同一类型中的实例方法和静态方法如果方法签名不同，也是允许使用相同的标识符作为方法名的。而在仓颉中，除重载函数外，禁止成员之间拥有相同名称。仓颉没有成员类型的概念，Java 的成员类型将被映射为仓颉的顶层类型，因此不可能存在相同名称带来的冲突。

    因此，为了符合仓颉的规则，如果存在上述的命名冲突， Java 镜像生成器将为实例成员变量的名称末端追加`_${type-name}`，为静态成员函数的名称末端追加`Static`。Java 侧的原名称依然将通过`@ForeignName`注解得以留存，例如：

    ```java
    public class Node {
        public int id;
        public Node(int id) { this.id = id; }
        public static int id(long x) { return (int)x; }
        public static int id(short x) { return x; }
        public int id() { return id; }
        public void id(int newId) { this.id = newId; }
    }
    ```

    将被镜像为：

    ```cangjie
    public open class Node {
        @ForeignName["id"]
        public var id_Node: Int32

        public init(arg0: Int32)

        @ForeignName["id"]
        public static func idStatic(arg0: Int64): Int32

        @ForeignName["id"]
        public static func idStatic(arg0: Int16): Int32

        public open func id(): Int32

        public open func id(arg0: Int32): Unit
    }
    ```

* Java 包名无法被保留，这是因为 Java 支持包间循环依赖，且大量的包存在循环依赖的用法，但仓颉则是禁止包间循环依赖的，如果保留 Java 包名将难以避免镜像得到的仓颉包间存在循环依赖从而导致仓颉侧编译失败。详情请参见[处理循环导入依赖](#处理循环导入依赖)章节。

### Java 基本类型

 Java 基本类型将被镜像为对应的仓颉值类型：

 Java 类型        | 仓颉类型
---------------- | ------------
`boolean`        | `Bool`
`byte`           | `Int8`
`short`          | `Int16`
`char`           | `UInt16`
`int`            | `Int32`
`long`           | `Int64`
`float`          | `Float32`
`double`         | `Float64`

### Java `class`与`interface`类型

Java `class`和`interface`类型定义将分别被镜像为仓颉`class`和`interface`类型定义，得到的类型定义将拥有`@JavaMirror`注解。`@JavaMirror`注解的有且仅有一个的字符串实参的值是被镜像的 Java 类型的完全限定名。如果 Java 类型的简单名称中不包含仓颉标识符所禁止的字符，那么镜像得到的仓颉类型的名称将保持与 Java 类型简单名称一致；否则，镜像得到的仓颉类型的名称将由特殊规则处理得到，例如 Java 类型的简单名称中包含`$`，或是一个嵌套类型（嵌套类型经`javac`编译得到的类型简单名称由其所在类型的简单名称和该类型的简单名称通过`$`拼接而成），这些`$`将被自动替换为下划线`_`。

被镜像的字段类型和方法的形参类型和返回类型`T`，如果是`class`或`interface`类型，将被自动装包为`Option<T'>`类型，其中`T'`是`T`的镜像类型。详情请参见[null 值处理](#java-null值处理)章节。

被`@JavaMirror`注解的类型定义与正常的仓颉类型定义存在若干差异：

* `@JavaMirror class`的继承层次结构的根类不是`std.core.Object`，而是一个内置镜像类[`java.lang.JObject`](#javalangjobject)。

* Java 的`java.lang.String`在仓颉侧的镜像是一个内置镜像类[`java.lang.JString`](#javalangjstring)。

* 镜像得到的类型定义中仅保留符号和类型信息，变量初始化器、函数体、属性体等均不会在`@JavaMirror`类型定义中体现。

示例如下，假设存在以下 Java 类定义：

```java
public class Node {
    public static final int A = 0xDeadBeef;
    private int id;
    public Node(int id) { this.id = id; }
    public int id() { return id; }
}
```

其镜像得到的`@JavaMirror`类可能如下：

```cangjie
@JavaMirror["Node"]
public open class Node {
    public static let A: Int32
    public init(id: Int32)
    public func id(): Int32
}
```

* 访问修饰符为`public`的 Java 类和接口会被镜像，其他则不会被镜像。

* 非`final`的 Java 类被镜像得到的仓颉类将拥有`open`修饰符。

* Java 的`sealed`、`non-sealed`以及遗留的`strictfp`修饰符均将被忽略。

* 访问修饰符为默认或`private`的构造方法、实例/静态字段、实例/静态方法不会被镜像。

* 静态初始化块和实例初始化块均不会被镜像。

* 如果 Java 类型的成员名称与镜像得到的仓颉类型的成员名称不同（原因请参考[Java 名称](#java-名称)小节），那么 Java 类型的成员名称信息将通过`@ForeignName`注解传递到仓颉侧，例如：

```java
    CurrencyAmount priceInUS$Per(WeightUnit wu) { ... }
```

```cangjie
    @ForeignName["priceInUS$Per"]
    public open priceInUS_Per(arg0: WeightUnit): CurrencyAmount
```

> **注意：**
>
> Java 和仓颉的访问修饰符`protected`的含义是不同的。
>
> 在 Java 中，`protected`成员的可见范围是**所在包**内，以及所在类的子类。
>
> 而在仓颉中，`protected`成员的可见范围是**所在模块**内，以及所在类的子类。
>
> 不过一般来说这个差异并不会导致任何问题。

**字段**将被镜像为成员变量，变量类型为字段类型相应的镜像类型；变量名称与字段名称保持一致（一般情况下如此，特殊情况请参见[Java 名称](#java-名称)小节）；实例字段将被镜像为实例成员变量，静态字段将被镜像为静态成员变量；访问修饰符`public`、`protected`将直接保留；非访问修饰符`transient`、`volatile`将被忽略；`final`字段将被镜像为`let`成员变量，非`final`字段将被镜像为`var`成员变量；字段初始化器将被忽略。

**方法**将被镜像为成员函数，其函数名与方法名保持一致（一般情况下如此，特殊情况请参见[Java 名称](#java-名称)小节）；其形参类型和返回类型为相应的镜像类型；返回类型为`void`的方法将被镜像为返回类型为`Unit`的成员函数；实例方法将被镜像为实例成员函数，静态方法将被镜像为静态成员函数；访问修饰符`public`、`protected`将直接保留；非访问修饰符`native`、`synchronized`及遗留的`strictfp`将被忽略；非`final`方法将被镜像为`open`成员函数。

**构造方法**将被镜像为构造函数，其形参类型均被替换为相应镜像类型；由于未定义构造方法而被隐式声明的默认构造方法也会被镜像；访问修饰符`public`、`protected`将直接保留。

> **注意：**
>
> 1. `@JavaMirror`类中禁止包含主构造函数。
> 2. `@JavaMirror`类中如果没有任何显式定义的构造函数，并不会像正常仓颉类那样存在隐式定义的构造函数，于是该类并不能通过调用构造函数来实例化。对于自动生成的`@JavaMirror`类，出现这种情况一般意味着被镜像的 Java 类中仅声明有访问范围为默认或`private`的构造方法，而这样做一般是有意阻止下游用户直接通过调用构造方法来实例化该类。
> 3. Java 镜像生成器的输入是`.class`文件，而方法/构造方法的形参名一般并不会保存在`.class`文件中，这种情况下，Java 镜像生成器会为生成的镜像自动合成形参名，诸如`arg0`、`arg1`。`javac`的编译选项`-parameters`可以使形参名得以在`.class`文件中留存，但只对`class`类型有效，`interface`类型则依旧无法保留。调试信息生成相关选项`-g`/`-g:vars`与之同理。

**成员类型**将被镜像为顶层类型定义，因为仓颉并不支持嵌套类型定义；镜像类型的名称是成员类型的二进制名称，也就是该成员类型的直接所在类型的二进制名称，加上`$`分隔符，再加上该成员类型自己的简单名称，如是递归得到，且由于仓颉标识符不支持`$`，所有`$`均被替换为下划线`_`（可参考[Java 名称](#java-名称)小节）；访问修饰符`public`、`protected`将直接保留；非访问修饰符`static`将被忽略；镜像类型的构造函数将新增一个额外的形参，该形参用于传入该成员类型直接所在类型的实例（在 Java 中，该形参是被隐式声明且被隐式传入的）。

```java
public class Outer {
    public static class Static {}
    public class Inner {}
    public Inner getInner() { return new Inner(); }
}
```

```cangjie
@JavaMirror["Outer"]
public open class Outer {
    public init()

    public open func getInner(): ?Outer_Inner
}

@JavaMirror["Outer$Static"]       // Original binary name is retained
public open class Outer_Static {  // '$' is replaced with '_'
    public init()
}

@JavaMirror["Outer$Inner"]       // Original binary name is retained
public open class Outer_Inner {  // '$' is replaced with '_'
    public init(p0: ?Outer)      // Extra parameter for enclosing instance
}
```

所有镜像得到的成员函数和构造函数均无函数体，代码外观上与正常仓颉的抽象成员函数相似。于是存在以下约束条件：

* 抽象方法的`abstract`修饰符将被保留，否则单从仓颉侧无法区分原 Java 方法是否是抽象的，例如：

    ```java
    public abstract class A {
        public void c() {}
        public abstract void a();
    }
    ```

    ```cangjie
    @JavaMirror["A"]
    public abstract class A {
        public init()

        public open func c(): Unit

        public open abstract func a(): Unit
    }
    ```

* 默认接口方法所镜像得到的成员函数将带有`@JavaHasDefault`注解，否则单从仓颉侧无法区分原 Java 接口方法是否拥有默认实现，例如：

    ```java
    public interface I {
        default void c() {}
        void a();
    }
    ```

    ```cangjie
    @JavaMirror["I"]
    public interface I {
        @JavaHasDefault
        func c(): Unit

        func a(): Unit
    }
    ```

> **注意：**
>
> 不支持数量可变参数​，对于拥有可变参数的方法，`, ...`部分将被忽略。

#### `@JavaMirror`类型的继承层次结构

`@JavaMirror`类和接口自成一套继承层次结构，也就是说：

* `@JavaMirror`类的继承层次结构的根类并不是`std.core.Object`，而是一个内置`@JavaMirror`类[`java.lang.JObject`](#javalangjobject)。

* `@JavaMirror`接口可以继承其他`@JavaMirror`接口，该继承关系反映的是原 Java 侧接口之间的继承关系。`@JavaMirror`接口禁止继承普通仓颉接口，普通仓颉接口也禁止继承`@JavaMirror`接口。

* `@JavaMirror`类可以继承其他`@JavaMirror`类，该继承关系反映的是原 Java 侧类之间的继承关系。`@JavaMirror`类禁止继承普通仓颉类，普通仓颉类也禁止继承`@JavaMirror`类。

* `@JavaMirror`类可以实现`@JavaMirror`接口，该实现关系反映的是原 Java 侧类和接口之间的实现关系。`@JavaMirror`类禁止实现普通仓颉接口，包括`std.core.Any`，普通仓颉类也禁止实现`@JavaMirror`接口。

#### Java 泛型

 Java 泛型在经`javac`编译得到`.class`的过程中将被擦除，故由 Java 镜像生成器自动生成的`@JavaMirror`类型总是非泛型的，且所有原泛型参数均被替换为其最左边界类型的相应镜像类型。

禁止手写泛型的`@JavaMirror`类型定义，但内置类型[`JArray<T>`](#javalangjarrayt)（详情请参见[Java 数组类型](#java-数组类型)小节）除外。

### Java 数组类型

[`JArray<T>`](#javalangjarrayt)是一个特殊的内置类型，其为 Java 数组类型的镜像类型。

元素类型为`T`的 Java 数组（即类型为`T[]`）被镜像为：

* `?JArray<T'>`，如果`T`是基本数据类型

* `?JArray<?T'>`，如果`T`是引用类型

其中`T'`是`T`的镜像类型。

有关为何进行`Option<T>`封装，请参见[null 值处理](#java-null值处理)章节。

> **注意：**
>
> Java 数组是协变的，而仓颉泛型是不变的，这个规格对于`JArray<T>`类型同样成立。

### Java 枚举类

 Java 枚举类`E`将被镜像为`@JavaMirror`类`E'`，该类直接继承`java.lang.Enum`类的镜像。`E'`既不可能是`open`也不可能是`sealed`，故无法被继承。

`@JavaMirror`类`E'`中包含有：

* Java 枚举常量的镜像，形式为可见性为`public`的`let`静态成员变量，变量类型为`E'`。

* Java 枚举类型中隐式定义的若干方法的镜像，即`public static E'[] values()`和`public static E' valueOf(String name)`。

* Java 枚举类型中所有访问范围为`public`/`protected`的字段和方法，其镜像规格与 Java 类的镜像规格完全一致。

`@JavaMirror`类`E'`中无任何显式定义的构造函数，且`@JavaMirror`类本身也不会隐式定义默认构造函数，从而杜绝了通过调用构造函数实例化`E'`的可能性。

### 特殊注意事项

### Java `null`值处理

仓颉没有空引用的概念，因此对 Java `null`类型没有直接对应物。假设一个 Java 方法的返回类型是引用类型`T`，如果该方法被镜像为仓颉成员函数后，成员函数的返回类型直接就是`T`的镜像类型`T'`，就将存在这个问题：当仓颉侧调用该成员函数，Java 侧的对应方法返回的是实例的引用时，仓颉侧的成员函数调用能够正常返回；但如果 Java 侧对应方法返回的是`null`值，则将直接导致段错误。反过来，这样同时也会使得仓颉侧无法传递`null`值回 Java 侧。

因此，如果 Java 侧的字段类型、数组元素类型、方法形参类型或返回类型等，是引用类型`R`，该实体的镜像所声明的类型将是`Option<R'>`，其中的`R'`是`R`的镜像类型。在仓颉侧，`None`代表的是`null`值，而`Some(r)`代表非`null`的引用值，其中`r`是类型为`R'`的值。为了实现上述规格，假设存在镜像类型或互操作类`T`， cjc 会将`Option<T>`识别为 Java 兼容类型，并据此对`T`值进行装包/拆包操作。

示例如下，对于以下的 Java `interface`：

```java
interface Concatenator {
    String concat(String[] ss);
}
```

形参`ss`本身可能为`null`，`ss`作为数组，其中每个元素都有可能为`null`，`concat`方法的返回值也同样可能为`null`。因此，对于该`interface`来说最保险的镜像的方式如下：

```cangjie
@JavaMirror
interface Concatenator {
    func concat(ss: ?JArray<?JString>): ?JString
}
```

同理，当开发者在互操作类中定义具有外部类型`T`的局部变量时，也应该使用`Option<T>`而不是直接`T`，除非开发者能百分之百确定该局部变量不会被赋`null`值。

```cangjie
    // 假设M是 Java 镜像类型
    let m: M = M() // 如果M()能够成功返回，开发者能够保证一定返回 M 实例而不是空引用
```

上述`Option<T>`封装保证了即便 Java 侧往仓颉侧传入空引用也不会导致程序崩溃，但这也同时引入了性能和内存占用代价，以及使得[型变被丢失](#型变丢失)。

#### 型变丢失

为 Java 镜像类型和互操作类进行[`Option<T>`装包](#java-null值处理)带来了一个显著的限制：向这样装包的类型在所有其他方面均完全遵循仓颉语义规则。具体而言，根据仓颉语义规则，`Option<T>`对其类型变元`T`是**不变**的，换句话说，对于两个类型`U`和`T`，除非`U`和`T`是相同的类型，否则即便`U`是`T`的子类型，`Option<U>`也与`Option<T>`不存在任何子类型关系。这意味着，对于镜像类型中存在重写关系的方法，如果这两个方法的返回类型存在**协变**的关系，这个协变的关系无法在仓颉侧保留下来，子类中的重写方法的返回类型的镜像必须改为父类中方法的返回类型的镜像。

示例如下，在以下代码片段中，`class Foo`是`class Bar`的父类：

```java
public class Foo {}

public class Bar extends Foo {}
```

`interface C`中的`get`方法的返回类型是`Foo`：

```java
public interface C {
    public Foo get();
}
```

`interface D`作为`interface C`的子类型，可以通过重写`get`方法，来让方法的返回类型更加精确，从`Foo`改为`Bar`：

```java
public interface D extends C {
    @Override
    public Bar get();
}
```

假设不进行`Option<T>`的装包，上述 Java 类型定义将被镜像为以下仓颉类型定义：

```cangjie
@JavaMirror
public open class Foo {}

@JavaMirror
public open class Bar <: Foo {}

@JavaMirror
public interface C {
    public open func get(): Foo
}

@JavaMirror
public interface D <: C {
    public override open func get(): Bar // 此处存在返回类型协变
}
```

但正如前文所述，若不进行`Option<T>`装包，而调用`get`实际返回`null`值，则不可避免地导致程序崩溃。

如果进行`Option<T>`装包，就可以解决`null`的问题，不过所有重写的成员函数的返回类型就不得不降级为原始的（定义在父类型中的）成员函数的返回类型：

```cangjie
@JavaMirror
public open class Foo {}

@JavaMirror
public open class Bar <: Foo {}

@JavaMirror
public open interface C {
    public open func get(): ?Foo
}

@JavaMirror
public open interface D <: C {
    // public open func get(): ?Bar    // 错误，Option<T> 对于 T 不协变，?Bar 不是 ?Foo 的子类型
    public open func get(): ?Foo       // 正确，但返回类型被降级了
}
```

 Java 的可空性注解，如`@Nullable`、`@NotNull`等，可以部分消减上述问题，但当前版本尚不支持此处理。

### 处理循环导入依赖

 Java 源码中普遍存在包间的循环导入，例如，Java 最基础的类，`java.lang`包中的`String`类依赖：

* `java.io`包中的`Serializable`接口
* `java.nio.charset`包中的`Charset`类
* `java.util`包中的`Locale`类

而上述的所有类型均无一例外依赖`java.lang`包中的`Object`类，从而构成循环导入依赖。

之所以 Java 允许循环导入依赖，是因为对于每个类型，都会被编译为单独的`.class`文件。而对于仓颉来说，假设一个仓颉包`a`导入另一个包`b`，则包`b`必须先于包`a`编译完毕，然后才能正常编译包`b`。因此，同属于一个仓颉包的所有源文件必须在同一次 cjc 编译中被编译得到一个单独的二进制文件。仓颉的最小编译单元是一个包，而不是像 Java 那样的单个源文件，故在仓颉源码中，包间循环导入依赖是禁止的。

#### 单包模式

由于上述的 Java 与仓颉之间的[区别](#处理循环导入依赖)，镜像生成器无法直接将原 Java 包名作为生成的仓颉包名。为了避免仓颉侧出现循环导入依赖，镜像生成器不得不总是将所有生成的镜像类型放在同一个仓颉包中，即便原 Java 类型来自于若干不同的 Java 包。这个仓颉包名于是是由用户决定的，通过`--package-name`选项指定，默认为`UNNAMED`。

举例来说，假设开发者运行镜像生成器，指定以下选项：

`--package-name java.world`

镜像生成器将把生成的仓颉类型放在`java.world`包中，而原 Java 包名则通过`@JavaMirror`注解的参数得以传递至仓颉侧：

```cangjie
package java.world

import java.lang.*

@JavaMirror["java.lang.Cloneable"]
public interface Cloneable {
}
```

#### Java 镜像类型名称冲突

不同 Java 包中可能定义有完全限定名不同，但拥有相同简单名称的类型。例如，JDK 的`javax.management`包中存在`Attribute`类，`javax.naming.directory`包中存在`Attribute`接口。显然，如果它们生成的镜像类型的简单名称不改名，同为`Attribute`，那么这两个类型的镜像类型无法同时存在在一个仓颉包中。因此，镜像生成器在[单包模式](#单包模式)下，将自动检测命名冲突，对所有存在冲突的类型名称进行修饰。具体而言，存在冲突的镜像类型的名称会采用原 Java 类型的完全限定名，其中的点`.`均替换为下划线`_`。

```cangjie
// src/java/world/src/javax_management_Attribute.cj
package java.world

import java.lang.*

@JavaMirror["javax.management.Attribute"]
public open class javax_management_Attribute <: Serializable {
   .  .  .
}
```

```cangjie
// src/java/world/src/javax_naming_directory_Attribute.cj
package java.world

import java.lang.*

@JavaMirror["javax.naming.directory.Attribute"]
public interface javax_naming_directory_Attribute <: Cloneable & Serializable {
   .  .  .
}
```

## Java 镜像生成器参考

### 准备工作

 Java 镜像生成器依赖 JDK17，在使用前请确保开发者本地已安装 JDK17 并配置好相应的`PATH`环境变量。

开发者需要知道本地所有需要为之生成镜像的 jar 文件的路径和`.class`文件所在目录的路径，这包括安卓标准库的 jar，以及安卓应用运行时的类路径等。

#### Java 镜像生成器命令行语法

共有两种使用 Java 镜像生成器的方式：

`java-mirror-gen [`_`options`_`] [`_`type-names`_`]`

这一种方式用于为一到若干个 Java 类或接口，及其所依赖的所有其他 Java 类型生成镜像。

`java-mirror-gen [`_`options`_`] -jar` _`jar-file`_   _(单 Jar 包模式)_

这一种方式则用于为指定的 jar 文件`jar-file`中包含的所有`.class`文件中的所有类型，以及其所依赖的所有其他 Java 类型生成镜像，注意，后者这些依赖的 Java 类型所在的`.class`文件可能并不在指定的 Jar 包中，而存在于其他类路径上（如果确实存在）。

在上述命令中：

* _`options`_ 是 Java 镜像生成器的若干[命令行选项](#java-镜像生成器命令行参数)。

* _`type-names`_ 是需要为之生成镜像的的 Java 类和接口的完全限定名。

* _`jar-file`_ 是单个 jar 文件的路径。

### Java 镜像生成器命令行参数

* `-a` _`pathname`_, `--android-jar` _`pathname`_   _(必选)_

    _`pathname`_ 必须是用于构建安卓项目的安卓 SDK 的`android.jar`文件的路径。该选项必须指定，且`android.jar`文件路径必须有效，否则将导致镜像生成器失败并打印报错信息。

* `-d` _`directory`_, `--destination` _`directory`_

    _`directory`_ 指定了一个目录路径，镜像生成器将把生成的镜像仓颉源文件放置在该目录中，放置的目录结构将遵循 CJMP 相关的要求。如果该选项未被指定，默认为当前目录。

* `-cp` _`path`_, `--class-path` _`path`_

    _`path`_ 是一系列的目录路径、jar 文件路径或 zip 文件路径，不同路径之间使用冒号`:`（非 Windows）或分号`;`（Windows）分隔。镜像生成器在为指定的类型 _`type-names`_ 及其依赖类型生成镜像时，将会在这些路径下尝试搜索这些类型。

* `-p` _`name`_, `--package-name` _`name`_

    _`name`_ 是仓颉包名，镜像生成器将把所有本次生成的镜像仓颉类型置于该包中。详情请参见[单包模式](#单包模式)。

* `-c` _`number`_, `--closure-depth-limit` _`number`_

   _`number`_ 为非负十进制整数值，限制了镜像生成类型在确定需要为哪些类型及其成员生成镜像时，其搜索依赖的深度。

* `-jar` _`jar-file`_

    _`jar-file`_ 是一个 jar 文件的路径，在单 jar 包模式下，镜像生成器将处理该 jar 文件。详情请参见[命令行语法](#java-镜像生成器命令行语法)。

* `-h`, `-?`, `--help`

    指定该选项， Java 镜像生成器将打印帮助信息，简要解释各命令行选项的用法然后终止。

* `-v`, `--verbose`

    指定该选项， Java 镜像生成器将详细输出其执行的操作步骤。

### Java 镜像生成器使用示例

```sh
java-mirror-gen \
    -android-jar $ANDROID_SDK/platforms/android-35/android.jar \
    -class-path ./classes \
    -destination ./mirrors \
    -p com.example \
    com.example.subpkg1.A com.example.subpkg2.B
```

```sh
java-mirror-gen \
    -a $ANDROID_SDK/platforms/android-35/android.jar \
    -cp ./lib \
    -d ./mirrors \
    -p javaworld \
    -jar App.jar
```

## 互操作库预置 API 参考

 CJMP 所提供的 Java 互操作库`java.lang`中预置了`java.lang.Object`和`java.lang.String`这两个基础 Java 类的镜像类型，以及一个对标 Java 数组的泛型镜像类型。

由于`Object`、`String`和`Array`在仓颉`std.core`包中均有同名的类型，为了避免[Java 镜像类型名称冲突](#java-镜像类型名称冲突)，这几个 Java 类型的镜像类型分别被改名为`JObject`、`JString`和`JArray<T>`。

为了提升互操作使用体验，这几个镜像类型中特别重命名了部分成员函数，也新增了若干成员函数，详情请参见下文阐述。

### `java.lang.JObject`

`java.lang.JObject`是整个 Java 镜像类和互操作类继承层次结构的根类，其本身是`java.lang.Object`的 Java 镜像类，不过删除了部分不支持的成员函数，重命名或新增了部分成员函数，以更好地与仓颉标准库保持协调。

> **注意：**
>
> 被删除的成员函数是`clone()`、`finalize()`和`getClass()`。由于`JObject`是所有镜像类的根类，这些被删除的成员函数在所有其他镜像类中自然也不可用。

```cangjie
package java.lang

@JavaMirror["java.lang.Object"]
open class JObject {
    public open func equals(obj: ?JObject): Bool

    public func hashCode(): Int64
    @ForeignName["hashCode"]
    public open func hashCode32(): Int32

    public func toString(): String
    @ForeignName["toString"]
    public open func toJString(): JString

    public func wait(timeoutMillis: Int64): Unit
    public func wait(timeoutMillis: Int64, nanos: Int32): Unit
    public func wait(): Unit
    public func notifyAll(): Unit
    public func notify(): Unit
}
```

`equals`以及所有`wait/notify`相关实例成员函数都是对应 Java 实例方法的镜像。

 Java 的`java.lang.Object`的`hashCode`方法的返回类型是`int`，对应仓颉`Int32`，而仓颉标准库中的`hashCode`成员函数的返回类型则是`Int64`。因此，`java.lang.JObject`内置了两个不同的`hashCode`成员函数来解决这个差异：

```cangjie
public func hashCode(): Int64
```

该实例成员函数将调用 Java 实例方法`hashCode`，并将 Java 侧的 32 位的`int`返回值强制类型转换为`Int64`，从而更符合仓颉开发者的习惯预期。而另一个实例成员函数：

```cangjie
@ForeignName["hashCode"]
public open func hashCode32(): Int32
```

则是原本的 Java 方法`hashCode`的镜像，为避免名称冲突而重命名为`hashCode32`。

```cangjie
public func toString(): String
```

该实例成员函数将调用原本的 Java 的`toString`实例方法，并将返回值转换为仓颉`String`。Java 侧`toString`方法的调用极低概率会返回`null`，但为了方便使用，并没有为此进行`Option<T>`装包，而是在返回`null`时，仓颉侧的`toString`实例成员函数将抛出异常。

> **注意：**
>
> 该成员函数的返回类型是仓颉`String`类型，这明显违反了规格，因为规格要求镜像类的所有`public`成员函数的形参类型和返回类型必须是 Java 兼容类型。之所以可行是因为 cjc 针对该成员函数有专门的支持。

```cangjie
@ForeignName["toString"]
public open func toJString(): JString
```

该实例成员函数是 Java 原方法`toString`的镜像类型，为避免名称冲突而改名为`toJString`。

同上述原因， Java 的`toString`方法极低概率返回`null`，故`toJString`函数返回类型设计为`JString`而不是`?JString`。

### `java.lang.JString`

```cangjie
package java.lang

@JavaMirror["java.lang.String"]
open class JString {
       .  .  .
    public init(cjString: String)
       .  .  .
}
```

```cangjie
public init(cjString: String)
```

将仓颉`String`实例转换为`JString`。

> **注意：**
>
> 该构造函数的形参类型是仓颉`String`类型，这明显违反了规格，因为规格要求镜像类的所有`public`构造函数的形参类型必须是 Java 兼容类型。之所以可行是因为 cjc 针对`JString`有专门的支持。

`JString`从[`JObject`](#javalangjobject)继承得到以下成员函数：`equals`、`hashCode`、`hashCode32`、`toString`、`toJString`、`wait/notify`等。

### `java.lang.JArray<T>`

`JArray<T>`是互操作库中内置的特殊泛型镜像类型，用作所有 Java 数组类型的镜像类型，类型变元`T`必须是能够映射至 Java 基本数据类型的值类型（例如`Int32`和`Bool`等）、镜像类型或互操作类。

当前版本存在以下使用限制：

* 不支持数组元素类型为可空引用的类型。换句话说，假设`T`是镜像类型或互操作类，则`JArray<T>`类型是支持的，而对元素类型进行了`Option<T>`装包的`JArray<?T>`类型则是不支持的。

* 不支持变量和形参的类型为可空引用的`JArray<T>`类型。也就是说，即便`JArray<T>`是支持的，`?JArray<T>`却是不支持的。

`JArray<T>`所提供的 API 相对仓颉原生`Array<T>`来说相对受限，除`JArray<T>`构造函数外，仅提供了用于获取数组长度的`length`实例成员属性、数组元素访问的操作符重载函数，以及由`java.lang.JObject`继承而来的若干成员函数。

```cangjie
public init(length: Int32)
```

实例化一个长度为`length`的 Java 数组。

```cangjie
public prop length: Int32
```

获取 Java 数组的元素个数。

```cangjie
public operator func [](index: Int32): T
public operator func [](index: Int32, value!: T): Unit
```

数组元素访问`[]`操作符重载函数。

`JArray<T>`从[`JObject`](#javalangjobject)继承得到以下成员函数：`equals`、`hashCode`、`hashCode32`、`toString`、`toJString`、`wait/notify`等。
