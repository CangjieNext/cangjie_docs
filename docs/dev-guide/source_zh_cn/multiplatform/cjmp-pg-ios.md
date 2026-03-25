# 仓颉-ObjC 互操作

> **注意：**
>
> 当前版本仅支持[在仓颉侧使用 Objective-C 的场景](#在仓颉侧使用-objective-c)，而[在 Objective-C 侧使用仓颉的场景](#在-objective-c-侧使用仓颉)则尚不支持。

仓颉跨平台方案支持开发者将仓颉语言接入 Android/iOS 应用开发，无论是项目中尚未实现的新逻辑，还是已存在的存量逻辑，都可通过仓颉语言完成开发与适配。

镜像类型是仓颉跨平台实现跨语言、跨运行时互操作的核心机制。它允许一门语言中定义的类型向另一门语言暴露接口，进而实现该类型在不同语言环境中的直接使用。

在仓颉侧，借助镜像类型，开发者无需脱离仓颉语法与语义规范，即可让仓颉类继承 Java 类/Objective-C 类，实现 Java 接口 /Objective-C 协议，而在 Java/Objective-C 侧，镜像类型同样能够让仓颉类型以对应语言的原生类型形式呈现。

在仓颉侧，镜像类型使得在依旧遵循仓颉语法和语义的情况下，仓颉 class 能够继承 Java 的 class/Objective-C 的 interface，实现 Java 的 interface/Objective-C 的 protocol。而在 Java/Objective-C 侧，镜像类型同样能够使得仓颉类型以各自语言的类型表示出来。总体来说，仓颉跨平台让仓颉和 Java/Objective-C 在 Android/iOS 应用工程中做到尽可能无缝衔接，同时也意味着，开发者可以在仓颉代码中，通过跨语言互操作直接调用对应操作系统提供的 API。

## 挑战与解决方法

仓颉、Java 和 Objective-C 虽然都是支持继承和多态的面向对象范式语言，但其各自的语义、底层实现的对象模型和执行模型等却存在显著差异，因此，试图在 Java/Objective-C 代码中直接使用仓颉语言，或反之在仓颉代码中直接使用 Java/Objective-C，均无法实现。

三种语言均各自拥有不同于其他两种语言的托管运行时，自动内存管理、线程模型、异常处理等底层特性各不相同。让两个复杂编程语言的运行时通过相互感知来实现互操作，无疑会让整个应用的复杂度剧增。

因此，仓颉跨平台对于仓颉与 Java 的互操作的实现思路是分别站在仓颉和 Java 侧，均将另一方视作低级语言。具体来说，仓颉与 Java 通过 Java 本地接口 (JNI) 实现互通。众所周知，JNI 用于使能 Java 调用例如 C/C++ 开发的本地接口，虽然功能强大，但作为底层 API，手写绑定层费时费力，不过好在 CJMP 提供了相应工具链，有效地消减了使用复杂度。

Objective-C 的运行时模块 API 在 iOS 平台上担任了与 JNI 在安卓平台上类似的角色，其也是为实现 Objective-C 与其他语言之间的桥接层。与上述的 JNI 的情况一样，CJMP 同样为开发者消减了其使用时繁琐的部分。

### 前置步骤

当前版本的 iOS 版仓颉 SDK 需要开发者手动到仓颉开源代码仓中下载获得`Cangjie.h`头文件：

[https://gitcode.com/Cangjie/cangjie_runtime/blob/dev/runtime/src/Cangjie.h](https://gitcode.com/Cangjie/cangjie_runtime/blob/dev/runtime/src/Cangjie.h)

然后将此头文件集成进 XCode 项目中，本文档后续将阐述的 Objective-C 互操作功能依赖此文件。

## 核心概念

### 镜像类型

不妨这样理解什么是镜像类型：仓颉和 Objective-C 一对语言之间进行互操作，若一种语言 A 的源码中定义有镜像类型`T'`，则意味着在另一种语言 B 的源码中实际存在由 B 语言定义的类型`T`。于是，在语言 A 的源码中就可以通过直接使用镜像类型`T'`来实现间接使用类型`T`，最终实现语言 A 仿佛直接使用语言 B 的类型的效果。该操作存在特定限制，将在下文中详细说明。

Objective-C 视角下，其`int`类型就是仓颉`Int32`类型在 Objective-C 侧的镜像类型；反过来，仓颉视角下，其`Int32`类型就是 Objective-C 的`int`类型在仓颉侧的镜像类型。不过，对于部分无法建立对应关系的数值类型来说，这个镜像关系就是不存在的了，例如仓颉的`Float16`在 Objective-C 侧就没有任何类型能够与之对应，故在 Objective-C 视角下就不存在一种镜像类型来匹配仓颉的`Float16`类型，也可以理解为，仓颉的`Float16`类型无法被镜像为任何 Objective-C 基本类型。

对于`class`、`struct`、`interface`和`enum`等用户自定义类型，语言 A 中的类型 `T` 在另一门语言 B 中的镜像类型`T'`，是在语言 B 中所能找到的尽可能最佳的等价类型。举例来说，仓颉的`struct`类型在 Objective-C 中所能找到的最佳等价类型是附加了`objc_subclassing_restricted`属性的 Objective-C`interface`。

若要在语言 B 中通过镜像类型使用语言 A 定义的类型，该镜像类型仅会暴露语言 A 原生类型中“理论上可被语言 B 访问和调用”的成员与构造函数。举例来说：若某个仓颉成员函数的返回类型为`Float16`，由于`Float16`无法被镜像为 Objective-C 类型，该仓颉成员函数也无法生成对应的镜像，导致 Objective-C 侧无法通过镜像类型调用此函数，这类场景需根据实际情况采用特定技巧解决。

正常情况下，无论是仓颉类型的镜像类型还是 Objective-C 类型的镜像类型，以及镜像类型本身依赖的其他类型的镜像类型，都能够以某种方式自动生成获得。CJMP 提供了一个独立的工具——[Objective-C 镜像生成器](#objective-c-镜像生成器参考)，来实现为 Objective-C 类型自动生成镜像类型；为仓颉类型生成镜像类型也同样是自动完成的，加上特定编译选项的 cjc 编译过程会将仓颉类型的镜像类型定义作为副产品生成，具体步骤将在本文档中详细解释。

#### 将 Objective-C 类型镜像为仓颉类型

cjc 在编译过程中会将所有仓颉源码中用到的 Objective-C 镜像类型替换为相应的胶水代码，这意味着，真正对编译结果起作用的核心信息只有两点：一是被使用的 Objective-C 镜像类型的名称，二是该镜像类型中各可用成员的名称及其类型。因此在编写仓颉代码时，Objective-C 镜像类型定义中只需要包含各个可用成员的声明就够了，换句话说，Objective-C 镜像类型中并不需要保留构造函数体、成员函数体和成员属性体，成员变量也不需要初始化器。另一方面，Objective-C 类型中定义的`@private`成员对仓颉侧来说不可见，因此这类成员同样不会出现在 Objective-C 镜像类型定义中。

显然，上述 Objective-C 镜像类型定义的写法是不符合仓颉语法/语义规格的，故 Objective-C 镜像类型定义必须带有`@ObjCMirror`注解，该注解用于在编译期协助 cjc 区分正常的仓颉类型定义与 Objective-C 镜像类型定义，从而对后者进行特殊处理。

示例如下，假设存在如下的 Objective-C `interface`：

```objectivec
@interface Node : NSObject {
}
- (id)initWith:(int)x;
- (int)getX;
@end
```

其对应的 Objective-C 镜像类型定义可能如下：

```cangjie
@ObjCMirror
public open class Node <: NSObject {
    @ForeignName["initWith:"]
    public init(x: Int32)
    public open func getX(): Int32
}
```

#### 将仓颉类型镜像为 Objective-C 类型

由于 cjc 专门的处理，Objective-C 镜像类型定义只需要保留最核心的信息即可，但仓颉镜像类型定义则必须是完整的正常的 Objective-C 类型定义，因为 iOS 工具链不会提供任何额外的特殊处理。在编译过程中，cjc 会将仓颉镜像类型定义生成为 Objective-C 源文件形式，该类型定义中包含完整的胶水层代码，这部分代码实现了仓颉与 Objective-C 两个运行环境之间的交互衔接。

假设前一个例子中的`Node`类型是由仓颉定义实现的，示例如下：

```cangjie
public class Node {
    private let _x: Int
    public func x(): Int { _x }
    public init(x: Int) { this._x = x }
}
```

那么 cjc 在编译上述代码块时将为其自动生成以下的仓颉镜像类型定义：

```objectivec
// Node.h
@interface Node : NSObject
- (id)init:(int64_t)x;
- (int)x;
@end
```

```objectivec
// Node.m
@implementation Node
- (id)init:(int64_t)x {
    /* Glue code constructing a Cangjie Node instance and associating
     * it with the Objective-C Node instance being constructed, i.e. 'self'.
     */
}
- (int64_t)x {
    /* Glue code invoking the 'x' member function of the associated
     * Cangjie Node instance and returning the result.
     */
     }
@end
```

### 全局函数镜像

Objective-C 和仓颉均支持顶级全局函数，此类函数不是任何其他类型的成员。它们以镜像函数的形式暴露给另一种语言，本质上就是自动生成的胶水层代码，用于在语言间传递控制权和数据。

### 互操作类

互操作类本质上是一个仓颉`class`，其从一到若干个镜像类型派生而来，这种仓颉`class`能够被 Objective-C 侧使用，这是因为其所有构造函数和非继承而来的`public`成员函数，都会通过一个由 cjc 在编译它时自动生成的共轭的 Objective-C 包装`interface`，对 Objective-C 代码暴露。这个 Objective-C 包装`interface`本身可能会定义若干辅助方法，但对于 Objective-C 侧代码来说，能调用的方法只有从仓颉侧暴露而来的，以及该`interface`继承而来的；仓颉侧代码也是同理。

接下来将举例说明，当使用 cjc 编译以下互操作类时：

```cangjie
@ObjCImpl
public class BooleanNode <: Node {
    private let _flag: Bool
    public init(x: Int32, flag: Bool) {
        super.init(x)
        this._flag = flag
    }
    public func flag(): Bool {
        _flag
    }
}
```

cjc 将同时生成一对 Objective-C 源码，其内容类似于以下代码块：

```objectivec
// BooleanNode.h
@interface BooleanNode : Node
/* glue code */
- (id)init:(int32_t)x:(BOOL)flag;
- (BOOL)flag;
/* more glue code */
@end
```

```objectivec
// BooleanNode.m
@implementation BooleanNode : Node
/* glue code */
- (id)init:(int32_t)x:(BOOL)flag {
    /* Glue code constructing a Cangjie BooleanNode(x, flag) instance and
     * associating it with the Objective-C instance being constructed,
     * i.e. 'self'.
     */
}
- (BOOL)flag {
    /* Glue code invoking the 'flag' member function of the Cangjie
     * BooleanNode instance associated with 'self' and returning the result.
     */
}
/* more glue code */
@end
```

### 外部类型

镜像类型和互操作类均有别于真正原生的自定义类型，故简洁起见，本文档中它们将被统一称作外部类型。

### Objective-C 兼容类型

以下仓颉类型均为 Objective-C 兼容类型：

* 所有拥有等价的 Objective-C 基本类型的仓颉值类型，例如`Int16`拥有等价的 Objective-C 基本类型`int16_t`，故`Int16`为 Objective-C 兼容类型；而`Float16`无等价的 Objective-C 基本类型，故`Float16`不是 Objective-C 兼容类型
* 所有外部类型
* `Option<T>`类型，且其中类型变元`T`为外部类型

显然，外部类型中定义的`public`的成员函数/方法的形参类型和返回类型必须是相应的兼容类型。

互操作类的`public`成员变量的类型可以是任意类型，但只有当成员变量的类型为 Objective-C 兼容类型时，该成员变量才可以在仓颉和 Objective-C 侧均可访问。

### 互操作使用场景

总体来说，共存在两种 Objective-C/仓颉互操作的使用场景：

* [仓颉侧所定义的类型和函数通过互操作对 Objective-C 侧代码暴露](#在-objective-c-侧使用仓颉)，从而使得 Objective-C 侧可以间接使用仓颉提供的 API、仓颉库与其他应用组件等。
* [Objective-C 侧所定义的类型通过互操作对仓颉侧代码暴露](#在仓颉侧使用-objective-c)，从而使得仓颉侧可以间接调用 iOS API、Objective-C 三方库与其他尚使用 Objective-C 编写的应用组件。

Objective-C 类可以继承仓颉类，实现仓颉接口，而仓颉类也可以继承 Objective-C 类，实现 Objective-C 协议，这使得在两种使用场景下均并非单向的从仓颉调用 Objective-C 或从 Objective-C 调用仓颉，而是仓颉和 Objective-C 之间灵活地互相调用，控制流得以互相转交。

由于两种场景各自拥有的功能特性、使用限制条件和工具支持情况等具有明显差别，下文将分别对两种使用场景进行阐述。

## 在 Objective-C 侧使用仓颉

Objective-C 侧访问仓颉库、调用仓颉 API 等的前提是开发者提前为所有相关的仓颉类型生成 Objective-C 侧能够使用的镜像类型。cjc 在编译仓颉源码过程中能够自动生成所需的镜像类型定义，详情请参见[仓颉镜像生成参考](#仓颉镜像生成参考)。

> **注意：**
>
> 仓颉语言的类型系统比 Objective-C 的更加丰富和灵活，即便是某些共有的语言特性，本质上也存在巨大差异，其中最典型的是[泛型](#为泛型仓颉类型进行镜像)，因此部分仓颉的语言特性完全无法在 Objective-C 中表达，而部分则难以用自然优雅的方式来表达。具体支持和限制情况请参见[仓颉到 Objective-C 的映射](#由仓颉到-objective-c-的映射关系)。

**例子:**

假设存在以下仓颉`struct Vector`类型需要暴露给 Objective-C 侧使用：

```cangjie
package cj

import interoplib.objc.*

public struct Vector {
    private let _x: Int32
    private let _y: Int32

    public prop x: Int32 { get() { _x } }
    public prop y: Int32 { get() { _y } }

    public init(x: Int32, y: Int32) {
        _x = x
        _y = y
    }

    public func add(v: Vector): Vector {
        Vector(x + v.x, y + v.y)
    }
}
```

首先开发者需要在`Vector`所定义的源文件中导入包`interoplib.objc`：

```cangjie
import interoplib.objc.*
```

在编译上述代码块时需为 cjc 新增两个额外的编译选项：`--experimental`和`--enable-interop-cjmapping=ObjC`，编译成功后将额外生成一对 Objective-C 源文件`Vector.h`和`Vector.m`，其中的内容类似如下：

```objectivec
// Vector.h
#import <Foundation/Foundation.h>
#import <stddef.h>

__attribute__((objc_subclassing_restricted))
@interface Vector : NSObject

/* glue code */

- (id)init:(int32_t)x :(int32_t)y;

@property (readonly, getter=x) int32_t x;
- (int32_t)x;
@property (readonly, getter=y) int32_t y;
- (int32_t)y;

- (Vector*)add:(Vector*)v;

/* glue code */

@end
```

```objectivec
// Vector.m

/* glue code */

@implementation Vector

/* glue code */

- (id)init:(int32_t)x:(int32_t)y {
    /* Glue code constructing an instance of Cangjie Vector(x, y) and associating
     * it with 'self'.
     */
}
- (int32_t)x {
    /* Glue code retrieving the value of the 'x' property of the
     * assocated instance of Cangjie Vector.
     */
}
- (int32_t)y {
    /* Glue code retrieving the value of the 'y' property of the
     * assocated instance of Cangjie Vector.
     */
}
- (Vector*)add:(Vector*)v {
    /* Glue code invoking the 'add' mmber function of the Cangjie Vector
     * instance associated with 'self', passing over the Cangjie Vector
     * instance associated with 'v', and wrapping the result in a new
     * instance of the Objective-C Vector class.
     */
}

/* more glue code */

@end
```

将`Vector.h`和`Vector.m`集成进 Xcode 项目中，接着就可以将这个`Vector`类型当作本来就是 Objective-C 编写的一样的类型来使用了：在 Objective-C 代码中定义`Vector*`类型的变量，创建`Vector`类型的实例，将实例作为方法入参，例如调用`[Vector add]`方法并将`Vector`类型的实例传入等。

**重要提示：当前版本的 iOS 版仓颉 SDK 要求使用者手动从仓颉开源仓中下载`Cangjie.h`头文件并将其添加到 XCode 项目中：**

[https://gitcode.com/Cangjie/cangjie_runtime/blob/dev/runtime/src/Cangjie.h](https://gitcode.com/Cangjie/cangjie_runtime/blob/dev/runtime/src/Cangjie.h)

### 限制暴露面

cjc 编译选项`--enable-interop-cjmapping`使得其所编的仓颉包中所有的`public`用户自定义类型均生成仓颉镜像类型，且这些用户自定义类型中的所有`public`成员和构造函数都会被暴露给 Objective-C 侧。但在实际开发场景中，这种全盘暴露的方式通常没有必要，因为 Objective-C 侧需要直接调用的仓颉接口，往往仅占整个仓颉库的很小一部分。

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

### 为泛型仓颉类型进行镜像

由于仓颉和 Objective-C 的泛型特性的实现存在根本性差异，仓颉泛型类型无法直接映射到 Objective-C 泛型类型以得到仓颉镜像类型。作为替代方案，CJMP 支持了仓颉镜像类型的单态化：用户通过配置文件为每个给定的仓颉泛型类型指定一个类型实参组合的列表，cjc 根据这个列表，对每个类型实参组合分别单独为该仓颉泛型类型生成一个非泛型的仓颉镜像类型，于是在 Objective-C 侧使用的都是非泛型的仓颉镜像类型。

> **注意：**
>
> 当前版本仅支持基本数据类型作为类型实参来单态化仓颉泛型类型。

举例来说，假设仓颉侧定义有如下泛型类型：

```cangjie
package p
public class Pair<T, U> { . . . }
```

如果希望在 Objective-C 侧能够使用`Pair<Int, Bool>`类型的实例，开发者可以在配置文件中`p`包所对应的`[[packages]]`配置块中添加`generic_object_configuration`配置项，具体配置内容如下：

```toml
##   .  .  .
[[packages]]
name = "p"
generic_object_configuration = [
    { name = "Pair", type_arguments = [ "Int, Bool" ] },
##       .  .  .
```

cjc 将生成以下非泛型的 Objective-C 类：

```objectivec
@interface PairIntBool
   .  .  .
@end
```

对应的是`Pair<T, U>`这个泛型类型的特定实例化结果的类型的仓颉镜像类型。

详情请参见[仓颉镜像生成参考](#仓颉镜像生成参考)的泛型实例化相关部分。

## 由仓颉到 Objective-C 的映射关系

当前版本的 cjc 采用本章所描述的仓颉到 Objective-C 的映射规则。关于相关的 cjc 命令行选项请参见[仓颉镜像生成参考](#仓颉镜像生成参考)。

### 一般注意事项

仓颉语言的类型系统较 Objective-C 而言更为丰富，不少仓颉类型及其相应的特性在 Java 中并不存在直接对应的等价的类型，有些则甚至连近似的类型也不存在，故在当前 CJMP 版本中，部分仓颉类型仅提供有限支持，而部分则完全不支持。

由于上述的限制，如果用户自定义类型中的`public`成员函数/成员属性/构造函数的形参类型/返回类型不存在对应的镜像类型，该成员函数/成员属性/构造函数本身也无法被镜像，但 cjc 并不会报错，而仅仅是忽略对其生成镜像。

仓颉镜像类型需要被独立编译成动态库，并禁用 ARC（通过为-objective-c-编译器指定`-fno-objc-arc`编译选项禁用）。

### 仓颉名称

仓颉包名、函数名、类型名称和类型成员的名称在镜像结果中都会完整保留原名，这也意味着，可能存在镜像后与 Objective-C 关键字冲突的情况，例如`int`等，或镜像类型中包含 Objective-C 禁止的用于构成名称的字符。

### 仓颉布尔类型和数值类型

对于仓颉布尔类型和数值类型，如果在 Objective-C 中存在对应等价类型，将被镜像为其对应类型，否则不支持镜像，详情请参见下表：

仓颉类型  | Objective-C 类型
------------- | -----------------
`Bool`        | `BOOL`
`Int8`        | `int8_t`
`Int16`       | `int16_t`
`Int32`       | `int32_t`
`Int64`       | `int64_t`
`Int`         | `int64_t`
`IntNative`   | `ssize_t`
`UInt8`       | `uint8_t`
`UInt16`      | `uint16_t`
`UInt32`      | `uint32_t`
`UInt64`      | `uint64_t`
`UInt`        | `uint64_t`
`UIntNative`  | `size_t`
`Float16`     | 不支持
`Float32`     | `float`
`Float64`     | `double`

关于如何处理不支持的类型，请参见[由仓颉到 Objective-C 的映射关系](#由仓颉到-objective-c-的映射关系)章节的一般注意事项。

### 仓颉`Rune`类型

不支持仓颉`Rune`类型。

关于如何处理不支持的类型，请参见[由仓颉到 Objective-C 的映射关系](#由仓颉到-objective-c-的映射关系)章节的一般注意事项。

### 仓颉特殊类型

仓颉`Unit`类型仅当作为函数返回类型时，被映射为 Objective-C 的`void`类型。

仓颉`Nothing`类型完全无法被映射，故不支持。

仓颉`Any`类型当前尚不支持。

关于如何处理不支持的类型，请参见[由仓颉到 Objective-C 的映射关系](#由仓颉到-objective-c-的映射关系)章节的一般注意事项。

### 仓颉元组类型

仓颉元组类型当前尚不支持。

关于如何处理不支持的类型，请参见[由仓颉到 Objective-C 的映射关系](#由仓颉到-objective-c-的映射关系)章节的一般注意事项。

### 仓颉`struct`类型

`public`仓颉`struct`类型定义将被映射为带有`objc_subclassing_restricted`属性的 Objective-C 类。相应的 Objective-C 侧类型定义由 cjc 在编译过程中自动生成，类型定义中包含胶水层代码，实现在 Objective-C 和仓颉之间传递控制和数据。自动生成的胶水层代码原则上禁止手动修改。

```cangjie
package cj

import interoplib.objc.*

public struct Vector {
    let x: Int32
    let y: Int32

    public init(x: Int32, y: Int32) {
        this.x = x
        this.y = y
    }

    public func add(v: Vector): Vector {
        Vector(x + v.x, y + v.y)
    }
}
```

```objectivec
// Vector.h
#import <Foundation/Foundation.h>
#import <stddef.h>
__attribute__((objc_subclassing_restricted))
@interface Vector : NSObject
// Auxiliary glue code methods
- (id)init:(int32_t)x :(int32_t)y;
- (Vector*)add:(Vector*)v;
// More auxiliary glue code methods
@end
```

```objectivec
// Vector.m

// Glue code

@implementation Vector

// Glue code

- (id)init:(int32_t)x :(int32_t)y {
    // Glue code creating an instance of Cangjie Vector(x, y) and
    // associating it with 'self'.
}
- (Vector*)add:(Vector*)v {
    // Glue code retireving instances of Cangjie Vector associated
    // with 'self' and 'v', invoking the add() member function
    // of Cangjie-self with Cangjie-v passed a parameter, and then
    // creating a new instance of Vector and associating it with the
    // result of the add() call.
}

// Glue code

@end
```

cjc 仅为`public`的`struct`成员和普通构造函数生成镜像。

**成员函数**将被镜像为方法，其方法名与仓颉成员函数名保持一致，其形参类型和返回类型均被替换为相应镜像类型。返回类型为`Unit`的成员函数将被镜像为返回类型为`void`的方法。实例成员函数将被镜像为实例方法（前缀为减号`-`），静态成员函数则被镜像为类方法（前缀为加号`+`）。

**成员属性**将被镜像为`@property`声明，其名称与仓颉成员属性名保持一致，其类型为仓颉成员属性的类型的镜像类型，且带有`readonly`属性。仓颉成员属性的`getter`将被镜像为无参方法，其方法名与仓颉成员属性名保持一致，其返回类型为仓颉成员属性的类型的镜像类型。

> **注意：**
>
> 当前仓颉成员属性的`setter`均不会被镜像，因此`mut`成员属性的镜像依然也是`readonly`的。

**成员变量**将被镜像为`@property`声明，其名称与仓颉成员变量名保持一致，其类型为仓颉成员变量的类型的镜像类型，且带有`readonly`属性。同时还会自动合成一个`getter`方法用于访问读取。

> **注意：**
>
> 当前对于`var`成员变量并不会为其自动合成`setter`方法，因此`var`成员变量的镜像依然也是`readonly`的。

**构造函数**将被镜像为实例方法，其方法名固定为`init`，其形参类型均被替换为相应镜像类型。

> **注意：**
>
> 默认的隐式定义的仓颉构造函数也将被镜像。

当前版本对可被镜像的`struct`类型施加了若干重大限制条件，以至于可以说需要针对被暴露给 Objective-C 侧的`struct`类型进行专门设计：

* 不支持成员函数构成重载：所有构成重载的成员函数被镜像后得到的所有方法均同名，从而导致命名冲突。

* 当前版本中，`let`和`var`成员变量均被镜像为`readonly`的`@property`，因此在 Objective-C 侧，即便是`var`成员变量也无法得以修改。该限制将在未来版本中移除，目前开发者可以通过在仓颉侧新增相应的`setter`成员函数作为规避手段。

* `mut`实例成员函数的镜像尚在实现中。它们会被镜像，但生成的胶水层代码在某些情况下是错误的。

* 被镜像的`struct`可能实现有除`Any`以外的其他`interface`，但这些接口实现的子类型关系信息并不会被传播到 Objective-C 侧：`@interface`后的类名后的尖括号对中并不会保留有任何这些被实现的`interface`的镜像类型名称。

* 操作符重载函数不会被镜像，在镜像生成过程中它们将被忽略。

* 支持通过单态化为泛型`struct`类型生成镜像，详情请参见[仓颉泛型](#仓颉泛型)章节。

* `struct`成员函数的形参类型和返回类型中如果含有不支持镜像的类型，cjc 不会报错，但该成员函数不会被镜像。

* `struct`构造函数的形参类型中如果含有不支持镜像的类型，cjc 不会报错，但该构造函数不会被镜像。

* 被镜像的`struct`类型可能拥有直接扩展和/或接口扩展，在镜像过程中被扩展的部分将被忽略。互操作并不影响仓颉侧对扩展部分的使用，扩展部分仅对 Objective-C 侧不可见。

* 禁止成员函数拥有类型形参。

### 仓颉`class`和`interface`类型

仓颉`class`和`interface`类型定义分别被镜像为 Objective-C 的类和`protocol`定义。相应的 Objective-C 侧类型定义由 cjc 在编译过程中自动生成，类型定义中包含胶水层代码，实现在 Objective-C 和仓颉之间传递控制和数据。自动生成的胶水层代码原则上禁止手动修改。

```cangjie
package cj

import interoplib.objc.*

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

```objectivec
// Valuable.h
@protocol Valuable
- (int64_t)value;
@end
```

```objectivec
// Singleton.h
// Glue code
@interface Singleton : NSObject
// Glue code
-(id)init:(int64_t)v;
- (int64_t)value;
// Glue code
@end
```

```objectivec
// Singleton.m
// Glue code
@implementation Singleton
// Glue code
-(id)init:(int64_t)v {
    if (self = [super init]) {
        // Glue code creating an instance of Cangjie Singleton(v)
        // and associating it with `self`.
    }
    return self;
}
- (int64_t)value {
    // Glue code calling the value() member function of the Cangjie
    // Singleton instance associated with 'self' and returning the result
}
// Glue code
@end

```

```objectivec
// Zero.h
#import "Singleton.h"
__attribute__((objc_subclassing_restricted))
@interface Zero : Singleton
// Glue code
- (id)init;
// Glue code
@end
```

```objectivec
// Zero.m
// Glue code
@implementation Zero
- (id)init {
    if (self = [super init]) {
        // Glue code creating an instance of Cangjie Zero()
        // and associating it with `self`.
    }
    return self;
}
@end
```

当前版本中，被镜像的类型的名称及其成员的名称，即便与 Objective-C 关键字冲突，也将得以保留。

非`open`仓颉`class`将被镜像为带`objc_subclassing_restricted`属性的 Objective-C 类。

`public`成员和构造函数均将被镜像。此外，`open class`的`protected open`实例成员函数也将被镜像，从而使得 Objective-C 侧定义子类时可以对其进行重写。除此之外的其他`class`和`interface`成员均不会被镜像。

> **注意：**
>
> 在 Objective-C 中没有任何包或命名空间或类似的概念，因此即便是`protected open`成员函数，在 Objective-C 侧的任何地方都可以调用相应方法。该行为不受到也无法受到像在仓颉侧的限制。

**成员变量**在当前版本中不会被镜像，因此 Objective-C 侧不存在任何直接访问仓颉成员变量的手段。

**成员属性**在当前版本中不会被镜像。

**成员函数**将被镜像为方法，其方法名与仓颉成员函数名保持一致，其形参类型和返回类型均被替换为相应镜像类型。返回类型为`Unit`的成员函数将被镜像为返回类型为`void`的方法。实例成员函数将被镜像为实例方法（前缀为减号`-`），静态成员函数则被镜像为类方法（前缀为加号`+`）。

**构造函数**将被镜像为实例方法，其方法名固定为`init`，其形参类型均被替换为相应镜像类型。

> **注意：**
>
> 默认的隐式定义的仓颉构造函数也将被镜像。
>
> 从外界看来，仓颉`class`和`interface`的镜像类型与正常的 Objective-C 类和`protocol`别无二致：它们可以被继承/实现，它们的方法可以与普通 Objective-C 方法构成重载，被普通 Objective-C 方法重写，可以查询获取它们的实例的类型，诸如此类。但两种语言终究存在差异，使得用户在 Objective-C 侧使用这些镜像类型时，需要特别关注一些潜在问题：

1. Objective-C 没有任何属性可以将一个方法标记为无法被重写，因此`open class`的非`open`成员函数虽然在仓颉侧无法被重写，但其镜像在 Objective-C 侧却可以被重写，但明显这么做是不应该的。

2. 当前实现中，`open class`的静态成员函数的镜像在 Objective-C 侧尚不支持重写。它们被镜像为 Objective-C 的类方法，不应该被在子类中重写。编译期无法施加此限制，故需要用户自行遵守。

3. 仓颉中，构造函数是不会被继承的，而在 Objective-C 中，名为`init`的方法与其他方法一样都是能够被继承的，因为 Objective-C 中没有单独的类似仓颉构造函数的概念，这潜在将导致某些不希望的效果。例如，请考虑如下仓颉类：

    ```cangjie
    public class A {
        public init() {...}
    }
    public class B <: A {
        private init() {...}
        public init(x: Int) {...}
    }
    ```

    在仓颉中，`class B`没有暴露其无参构造函数，然而`B`的镜像类却会从`A`的镜像类中继承得到`A`的无参构造函数。对于`[[B alloc] init];`这个表达式，其能够编译成功并运行，但当调用`init`方法时实际上会在仓颉侧实例化`A`，并将`A`的实例与`B`的镜像类型的实例的`self`关联，然而明显我们正常应该是预期`B`的实例与之关联。

> **注意：**
>
> 仓颉`open class`的镜像在实现上依赖的 Objective-C 底层特性与自动引用计数（ARC）不兼容。这就是为什么一般来说建议将所有镜像类型编译为单独的动态库，编译时指定禁止 ARC（通过`-fno-objc-arc`选项）。

当前版本对可被镜像的`class`和`interface`类型施加了若干重大限制条件，以至于可以说需要针对被暴露给 Objective-C 侧的`class`和`interface`类型进行专门设计：

* 不支持对抽象类生成镜像，抽象类将在镜像生成过程中被忽略，cjc 既不报错也不告警。

* 不支持对继承了抽象类的非抽象类生成镜像，如果尝试生成，镜像类源码虽然会被生成，但将编译失败。

* 不支持成员函数构成重载：所有构成重载的成员函数被镜像后得到的所有方法均同名，从而导致命名冲突。

* 暂不支持对成员变量生成镜像，因此 Objective-C 侧无法直接访问成员变量。该限制将在未来版本中被移除。当前可以手动在仓颉`class`中新增相应`getter/setter`成员函数来作为规避手段。

* 暂不支持对实现了除`Any`外的`interface`的仓颉`class`生成镜像，因为接口实现信息在镜像生成过程中被丢失了。

* 支持通过单态化为泛型`class`类型生成镜像，详情请参见[仓颉泛型](#仓颉泛型)章节。

* 仓颉`class`如果拥有`public`成员属性、操作符重载函数或主构造函数，将无法被镜像，cjc 既不会报错也不会告警，而是直接忽略之。

* 仓颉`interface`如果拥有成员属性、操作符重载函数，将无法被镜像，cjc 既不会报错也不会告警，而是直接忽略之。

* 成员函数形参类型支持`Bool`和数值类型，返回类型支持`Unit`、`Bool`和数值类型。构造函数形参类型支持`Bool`和数值类型。

* 特别地，对于非`open` `class`中定义的成员函数和构造函数，其形参类型和返回类型支持为定义在同包中的`struct`、`enum`和非`open` `class`类型（当前暂不支持定义在非当前包中的用户自定义类型作为形参或返回类型）。

* 成员函数的形参类型和返回类型中如果含有尚不支持的类型，cjc 既不会报错也不会告警，但该成员函数不会被镜像。

* 构造函数的形参类型中如果含有尚不支持的类型，cjc 既不会报错也不会告警，但该构造函数不会被镜像。

* `interface`之间的继承关系在镜像生成过程中不被保留。

* `class`与`interface`之间的实现关系在镜像生成过程中不会被传播到 Objective-C 侧，这层信息将被丢失。例如，注意到在上述例子中，`Singleton.h`中定义的`@interface Singleton`之后并 _没有_ `<Valuable>`，也就是说，在仓颉侧`class Singleton`实现`interface Valuable`的实现关系并没有反映在 Objective-C 侧。

* 被镜像的`class`类型可能拥有直接扩展和/或接口扩展，但在镜像过程中，被扩展的部分将被忽略。互操作并不影响仓颉侧对扩展部分的使用，扩展部分仅对 Objective-C 侧不可见。

* 禁止`class`或`interface`的成员函数拥有类型形参。

### 仓颉`enum`类型

`public`仓颉`enum`类型定义将被映射为带有`objc_subclassing_restricted`属性的 Objective-C 类，各构造器被镜像为类方法，Objective-C 类中无任何`public`的`init`方法。相应的 Objective-C 侧类型定义由 cjc 在编译过程中自动生成，类型定义中包含胶水层代码，实现在 Objective-C 和仓颉之间传递控制和数据。自动生成的胶水层代码原则上禁止手动修改。

```cangjie
public enum TimeUnit {
    | Year(Int)
    | Month(Int)
    | Year
    | Month
}
```

```objectivec
__attribute__((objc_subclassing_restricted))
@interface TimeUnit : NSObject
// Glue code
+ (TimeUnit*)Year:(int64_t)p1;
+ (TimeUnit*)Month:(int64_t)p1;
+ (TimeUnit*)Year;
+ (TimeUnit*)Month;
// Glue code
@end
```

**构造器**被镜像为类方法，方法名与构造器名保持一致，形参类型列表与构造器关联类型列表一一对应为其镜像类型，各形参名称均自动合成（`p1`、`p2`、...、`pn`）。

仅为所有`public`的枚举成员进行镜像。

**成员函数**将被镜像为方法，其方法名与仓颉成员函数名保持一致，其形参类型和返回类型均被替换为相应镜像类型。返回类型为`Unit`的成员函数将被镜像为返回类型为`void`的方法。实例成员函数将被镜像为实例方法（前缀为减号`-`），静态成员函数则被镜像为类方法（前缀为加号`+`）。

**成员属性**将被镜像为`@property`声明，其名称与仓颉成员属性名保持一致，其类型为仓颉成员属性的类型的镜像类型，且带有`readonly`属性。仓颉成员属性的`getter`将被镜像为无参方法，其方法名与仓颉成员属性名保持一致，其返回类型为仓颉成员属性的类型的镜像类型。

> **注意：**
>
> 当前仓颉成员属性的`setter`均不会被镜像，因此`mut`成员属性的镜像依然也是`readonly`的。

当前版本对能被镜像的`enum`类型施加了诸多限制条件：

* 不支持成员函数构成重载：所有构成重载的成员函数被镜像后得到的所有方法均同名，从而导致命名冲突。

* 被镜像的`struct`可能实现有除`Any`以外的其他`interface`，但这些接口实现的子类型关系信息并不会被传播到 Objective-C 侧：`@interface`后的类名后的尖括号对中并不会保留有任何这些被实现的`interface`的镜像类型名称。

* 当前尚不支持对拥有操作符重载函数的`enum`生成镜像。目前实现下，如果试图对拥有操作符重载函数的`enum`生成镜像，生成的镜像中 Objective-C 代码是无效的。

* 当前尚不支持为泛型`enum`生成镜像。未来将支持通过单态化为泛型`struct`类型生成镜像，详情请参见[仓颉泛型](#仓颉泛型)章节。

* 对于`enum`成员函数和构造函数，形参类型仅支持`Bool`和数值类型。

* 对于`enum`成员函数，返回类型仅支持`Unit`、`Bool`和数值类型。

* `enum`成员函数的形参类型和返回类型中如果含有尚不支持的类型，cjc 既不会报错也不会告警，但该成员函数不会被镜像。

* `enum`构造函数的形参类型中如果含有尚不支持的类型，cjc 既不会报错也不会告警，但该构造函数不会被镜像。

* 被镜像的`enum`类型可能拥有直接扩展和/或接口扩展，在镜像过程中被扩展的部分将被忽略。互操作并不影响仓颉侧对扩展部分的使用，扩展部分仅对 Objective-C 侧不可见。

* 禁止成员函数拥有类型形参。

支持递归定义的枚举类型，例如：

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

Objective-C 和仓颉的泛型存在本质性的差异，使得仓颉泛型无法被镜像为 Objective-C 泛型。然而，仓颉泛型的具体实例化后的类型（例如`G<Int64>`）是具体类型，而具体类型则可以被镜像为非泛型的 Objective-C 类型。像这样的具体类型被称为单态化了的泛型类型。

> **注意：**
>
> 当前版本存在以下限制：
>
> * 当前能用于单态化泛型类型的类型实参仅支持基本数据类型。
> * 禁止被镜像的成员函数拥有自己的类型形参。

开发者可以通过在[配置文件](#仓颉镜像生成配置)中指定需要为哪些泛型类型的哪些实例化的具体类型生成镜像，详情请参见[泛型实例化配置](#为泛型仓颉类型进行镜像)。

**例子:**

用 cjc 编译以下仓颉泛型`class`时：

```cangjie
public class G<T> {
    private let _t: T
    public init(t: T) { _t = t }
    public func get(): T { _t }
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

### 仓颉侧`nil`值处理

由于仓颉侧没有`nil`值的概念，任何从 Objective-C 侧传到仓颉侧的`nil`值都将导致从仓颉侧抛出`NullPointerException`异常。

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

```objectivec
__attribute__((objc_subclassing_restricted))
@interface Node
/* glue code */
- (id)init;
- (id)init:(Node *)next;
/* glue code */
@end
   .  .  .
     Node *list = [[Node alloc] init:nil];   /* NullPointerException */
```

反过来，无法通过返回类型为 Objective-C 兼容类型的`public`成员函数从仓颉侧返回`nil`值到 Objective-C 侧。

> **注意**
>
> 当前版本支持自动的`Option<T>`装/拆包，`nil`值被映射为`None`，但该装/拆包仅支持由 Objective-C 对象指针镜像而来的仓颉类型，而反过来仓颉自定义类型则不支持。详情请参见[Objective-C 侧`nil`值处理](#objective-c-侧-nil-值处理)。

## 仓颉镜像生成参考

仓颉 SDK 中提供了专门为 Java 类型生成镜像类型的独立工具`java-mirror-gen.jar`，也提供了专门为 Objective-C 类型生成镜像类型的独立工具`ObjCInteropGen`，而为仓颉类型生成镜像类型的职责则直接由 cjc 所承担：cjc 能够在编译仓颉源码的同时为仓颉类型生成镜像类型。

### 命令行选项参考

以下若干 cjc 编译选项将使能并控制如何在编译期为仓颉类型生成镜像类型：

`--experimental`    _(必选)_

当前版本下，该编译选项必须指定，因为整个跨平台互操作特性尚在开发中，待开发完毕后则将不再需要。

`--enable-interop-cjmapping=Java` _或_
`--enable-interop-cjmapping=ObjC`     _(必选)_

该编译选项将使能 cjc 为仓颉类型生成镜像类型，当值为`Java`时，生成的是 Java 版本的镜像类型；当值为`ObjC`时，则生成的是 Objective-C 版本的镜像类型。

`--output-interop-cjmapping-dir` _`pathname`_     _(可选)_

该编译选项指定了一个目录，cjc 将把生成的包含镜像类型定义（Java 或 Objective-C 源码）的源文件放置在该目录下。如果`pathname`所对应的路径尚不存在，cjc 将创建该目录；如果`pathname`路径已存在，且并非目录，cjc 则将不进行镜像类型生成并报错。

该编译选项可选，如果未指定，则默认为`./java-gen`或`./objc-gen`，取决于`--enable-interop-cjmapping`选项值为`Java`或`ObjC`。

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

`generic_object_configuration`    _(可选)_

该配置项的值是一个数组，数组中的每一个元素是一个表，每个表指定了针对一个泛型类型，需要为其生成哪些具体类型的镜像类型。一个表中包含以下属性：

`name`

该属性是一个`public`类型的简单名称，该类型需定义在名为其所在`[[packages]]`的`name`的包中。

`type_arguments`

该属性是一个字符串数组，每个字符串是一个**有效的**类型实参列表。

> **注意：**
>
> 当前版本仅支持`Unit`、`Bool`和数值类型作为此处用于泛型单态化的类型实参，如果用到了任何不支持的类型将导致编译报错。
>

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
    public class G<T> { . . . }
    public func f<T>(): Unit { . . . }
    public struct S<T, U> { . . . }
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

## 在仓颉侧使用 Objective-C

在第一种使用场景中，仓颉侧定义的类型被镜像后，在 Objective-C 侧可以完全自然地使用，例如对`class`实例化并作为入参四处传递等，详细介绍请参见[在 Objective-C 侧使用仓颉](#在-objective-c-侧使用仓颉)。

而在第二种使用场景中则是反过来的，Objective-C 的类和协议被镜像为仓颉类和接口，在仓颉侧可以对这些镜像类型进行拓展、实现和实例化等操作。然而，第二种使用场景下所支持的特性和限制与第一种显然存在差异，生成镜像所用的工具也是不同的：Objective-C 类型和全局函数的镜像由仓颉 SDK 中所提供的一个[独立工具](#objective-c-镜像生成器参考)所生成，而并非 cjc。

因此，第二种使用场景的具体操作步骤相较于第一种使用场景来说更为复杂，具体如下：

1. 基于 Objective-C 类型和函数，设计互操作胶水层。
   开发者 -> 互操作胶水层设计（Objective-C 伪代码）

2. 根据上一步设计的胶水层，为所有现存相关的 Objective-C 类和协议借助 Objective-C 镜像生成器生成仓颉侧可用的`@ObjCMirror`类型定义。
    `.h` -Objective-C 镜像生成器-> `.cj`（镜像类型定义）

3. 使用仓颉编写实现互操作层，仓颉代码中按需使用`@ObjCMirror`镜像类型，例如创建镜像类型的实例，调用其成员函数等。
    互操作胶水层设计 + `.cj`（镜像类型定义）-开发者-> `.cj`（胶水层实现）

4. 将`@ObjCMirror`镜像类型定义和第 3 步中使用仓颉实现的互操作层一起使用 cjc 编译，编译将得到：
    * 包含互操作层逻辑的动态库。
    * 若干 Objective-C 侧可用的镜像类型定义源文件。
    `.cj`（镜像类型定义 + 胶水层实现）-cjc-> `.dylib` + `.h`/`.m`（胶水层镜像类型定义）

5. 将以下中间产物添加进 XCode 工程:
    * 第 4 步中由 cjc 编译产生的若干`.h`/`.m`源文件，其中包含后续 Objective-C 侧可能用到的互操作胶水层代码。
    * 第 4 步中由 cjc 编译得到的`.dylib`动态库文件，其中包含了由仓颉实现的胶水层逻辑。
    * 仓颉 SDK 中所有必要的运行时库，包括`.dylib`等。

    接着，在 Objective-C 侧编写必要的对胶水层中提供的镜像类型的实例化和方法调用，完成后重构建工程即可。
    XCode 工程 + `.h` + `.m` + `.dylib` -iOS 工具链-> iOS 应用

**重要提示：当前版本的 iOS 版仓颉 SDK 要求用户手动从仓颉开源仓中下载`Cangjie.h`头文件并将其添加到 XCode 项目中：**

[https://gitcode.com/Cangjie/cangjie_runtime/blob/dev/runtime/src/Cangjie.h](https://gitcode.com/Cangjie/cangjie_runtime/blob/dev/runtime/src/Cangjie.h)

### 从零实现互操作层

#### 基础环境配置

1. 安装`llvm@16`：

    ```bash
    brew install llvm@16
    ```

2. 将`llvm@16/lib/`的路径添加至`DYLD_LIBRARY_PATH`环境变量：

    ```bash
    export DYLD_LIBRARY_PATH=/opt/homebrew/opt/llvm@16/lib:$DYLD_LIBRARY_PATH
    ```

3. 执行仓颉 SDK 中的`envsetup.sh`进行仓颉环境初始化。

4. 在终端执行以下命令来确认环境是否配置成功：

    ```bash
    ObjCInteropGen
    ```

    如果能够正常打印出 Objective-C 镜像生成器的帮助信息，则说明配置成功，可以继续进行下述的步骤了。

#### 步骤一：设计互操作层

在这一步，开发者需要**从 Objective-C 源码的视角**，来设计一到若干个[互操作类](#互操作类)。互操作类由仓颉编写实现，但最终会由 cjc 编译生成镜像类以便 Objective-C 侧使用，因此在 Objective-C 侧看来，并不关心互操作类的具体实现，而只需要关心 Objective-C 侧需要哪些功能。因此，对每个[互操作类](#互操作类)，开发者只需要考虑以下要点：

* 互操作类是继承`NSObject`，还是需要继承其他 Objective-C 类？
* 互操作类是否需要实现任何 Objective-C 协议？
* 互操作类中需要拥有哪些`public`/`protected`构造方法/成员方法？开发者目前只需要知道它们的功能以确定其函数签名，真正的实现则是在后续步骤中通过仓颉编写。

另请参见[互操作类的特性与限制](#互操作类的特性与限制)。

在 Objective-C 源码的视角下，互操作层所提供的 Objective-C 类与普通的 Objective-C 类在外观和使用上不存在任何区别，唯一区别在于后者的`@implementation`是用户自己手写的，而前者的`@implementation`则是用户手写仓颉`ObjCImpl class`后，由 cjc 编译之自动生成的。因此，开发者要做的是用伪代码来描述 Objective-C 侧的`@interface`，然后使用仓颉来照着这个`@interface`来依次实现各个方法，详情请参考[步骤三](#步骤三实现互操作类)。

**支持的形参类型：** 任何[被映射](#将-objective-c-类型镜像为仓颉类型)的 Objective-C 类型。

**支持的返回类型：** 任何[被映射](#将-objective-c-类型镜像为仓颉类型)的 Objective-C 类型或`void`类型。

**支持的继承与实现关系：** 互操作类只能继承 Objective-C 类的镜像类`@ObjCMirror class`，不能继承其他互操作类，且只能实现 Objective-C 协议的镜像接口`@ObjCMirror interface`。

**当前存在的使用限制：**

* 不支持拥有变长形参列表（varargs）的方法。

* 互操作类禁止拥有类型形参，互操作类的非`private`成员函数禁止拥有类型形参。

* 泛型 Objective-C 类型在镜像生成前，其泛型会被擦除，各个类型变元会被替换为各个类型上界。

**端到端示例：**

假设开发者的 iOS 应用源码中存在一个类`M`，类中定义有一个无参且返回类型为`void`的实例方法`foo`：

```objectivec
// M.h
#import <Foundation/Foundation.h>

@interface M : NSObject
- (void)foo;
@end
```

```objectivec
// M.m
#import "M.h"

@implementation M
- (void) foo {
    printf("Hello from ObjC M.foo()\n");
}
@end
```

开发者希望在仓颉侧定义一个继承类`M`的类`A`，其中对方法`foo`进行重写。

那么，开发者的互操作类的设计应该类似如下：

```objectivec
#import "M.h"

@interface A : M
- (void)foo;
@end
```

#### 步骤二：生成镜像类型

开发者需要为上一步中设计的互操作类所依赖的所有 Objective-C 类型生成其仓颉侧可用的[镜像类型](#镜像类型)，这包括互操作类的父类型、成员属性类型、形参和返回类型等，如果涉及数组类型，则还包括其元素类型。

不过在此之前，请正常构建 iOS 应用项目，不需要改任何东西，确保能够编译构建成功，这样能保证接下来镜像生成器所接收的 Objective-C 头文件是完整且连贯的。

接着，编写[镜像生成器配置文件](#objective-c-镜像生成器配置文件语法)，并运行镜像生成器：

```bash
ObjCInteropGen --mode=normal <config-file>
```

其中`<config-file>`是配置文件的路径。

**端到端示例（续）：**

类`A`唯一依赖的 Objective-C 类型是其父类`M`，于是配置文件应如下：

```toml
## A.toml
## Place the mirror of M and any dependencies it may have in the 'cjworld' package:
[[packages]]
filters = { include = ["M", "NS.+"] }
package-name = "cjworld"

## Write the output files with mirror type definitions to the current directory:
[output-roots.default]
path = "."

## Specify the pathname of the input header:
[sources.all]
paths = ["M.h"]

[sources-mixins.default]
sources = [".*"]
arguments-append = [
    ## Uncomment the following line if you get "unknown type name" errors
    ## "-DTARGET_OS_IPHONE=1",

    ## Edit the pathnames below to match the locations of Objective-C headers on your system:
    "-F", "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/System/Library/Frameworks",
    "-isystem", "/Library/Developer/CommandLineTools/usr/lib/clang/17/include",
    "-isystem", "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include"
]
```

镜像生成器命令行如下：

```bash
ObjCInteropGen --mode=normal A.toml
```

以上命令将在当前目录生成`cjworld/M.cj`，文件中保存有类`M`的镜像类型定义；以及若干`cjworld/NS*.cj`文件，分别保存有类`M`所依赖的 Foundation 框架中的类和协议的镜像类型定义。

##### 常见错误配置问题

**镜像生成器无法找到某些标准库的头文件，例如`stdarg.h`或`stdbool.h`等。**

典型报错信息：

```bash
..../CoreFoundation.h:19:10: error: 'stdarg.h' file not found
```

一般是由于`[sources-mixins]`表中`arguments-append`数组中的路径设置错误导致的，请仔细检查这些头文件搜索路径下确实存在相应头文件。

**镜像生成器产生“Unknown type name 'NSUInteger'”或类似报错。**

典型报错信息：

```bash
.../NSObjCRuntime.h:626:74: error: unknown type name 'NSUInteger'
```

某些时候，开发者需要给 clang 传入额外的参数，要么“`-DTARGET_OS_IPHONE=1`”或“`-DTARGET_OS_OSX=1`”。

将该额外的参数加入`[sources-mixins]`表中的`arguments-append`数组，在上述示例中，该配置被注释了：

```toml
   .  .  .
arguments-append = [
    ## Uncomment the following line if you get "unknown type name" errors
    ## "-DTARGET_OS_IPHONE=1",
   .  .  .
]
```

#### 步骤三：实现互操作类

对于开发者在[步骤一](#步骤一设计互操作层)中设计的互操作层中的各个 Objective-C 类骨架，现在需要分别为之编写一个仓颉类（即互操作类）：

* 创建源文件，选择一个合适的包名。
* 导入包`interoplib.objc.*`。
* 导入开发者在[步骤二](#步骤二生成镜像类型)中生成的镜像类型，不过请不要将所有生成的依赖的镜像类型全部导入进来，只需要导入实际将用到的那些镜像类型。
* 开始编写互操作类，为互操作类添加`@ObjCImpl`注解。
* 根据开发者的设计，让互操作类继承某`@ObjCMirror open class`；如果并不需要特别继承某父类，则让其继承`NSObject`。
* 实现互操作类中的构造函数及其他成员，为其中`public`的构造函数和成员函数添加`@ForeignName["`_`foreign-name`_`"]`注解，其中 _`foreign-name`_ 是开发者希望的 Objective-C 方法名，并遵守以下规定：

    1. 如果一个成员函数重写了父类的成员方法，请不要为该成员函数添加`@ForeignName`注解，否则将导致编译报错。

        > Objective-C 中，一个方法重写另一个方法，重写方法名必须与被重写方法名相同，其中，被重写方法的方法名已经从 Objective-C 侧通过镜像生成器自动传播至仓颉侧，保存于镜像类的相应成员函数的`@ForeignName`注解中（详情请参见[Objective-C 类和协议](#objective-c-类和协议)小结），cjc 将从该注解中获取原方法名。

    2. 对于拥有两个及以上形参的构造函数和非重写成员函数，请为其添加`@ForeignName`注解，否则将导致编译错误。

        > 对于拥有两个及以上形参的构造函数和成员函数，cjc 无法为其自动推导出一个有效的 Objective-C 方法名。

    3. 对于构成函数重载的构造函数和成员函数，请务必为其通过`@ForeignName`注解赋予不同的 Objective-C 方法名。这是因为 Objective-C 不存在“方法重载”的概念。

    4. 对于其他剩下的构造函数和成员函数，可选地为其添加`@ForeignName`注解即可。对于未被`@ForeignName`注解的构造函数或成员函数，如果无参，则其在 Objective-C 侧的方法名与原函数名相同（对于构造函数而言是`init`）；如果有且仅有一个形参，则其在 Objective-C 侧的方法名为原函数名加一个`:`后缀（对于构造函数而言是`init:`）。

> **注意：**
>
> 当前版本的 cjc 并不会全面校验 _`foreign-name`_ 的合法性。特别地，cjc 并不会校验 _`foreign-name`_ 中冒号`:`的数量是否与构造函数/成员函数的形参个数一致。

* 请参考以下 Objective-C 类型到仓颉类型的映射关系表（`T'`是对应的值类型或镜像类型）：

    Objective-C            | 仓颉       | 备注
    ---------------------- | ------------  | ------
    `void`                 | `Unit`        | -
    `BOOL`                 | `Bool`        | -
    `signed char`          | `Int8`        | -
    `short`                | `Int16`       | -
    `int`                  | `Int32`       | -
    `long`                 | `Int64`       | -
    `long long`            | `Int64`       | -
    `unsigned char`        | `UInt8`       | -
    `unsigned short`       | `UInt16`      | -
    `unsigned int`         | `UInt32`      | -
    `unsigned long`        | `UInt64`      | -
    `unsigned long long`   | `UInt64`      | -
    `float`                | `Float32`     | -
    `double`               | `Float64`     | -
    `struct`               | `@C struct'`  | (\*)
    `enum`且底层类型为`T` | `T'`          | -
    `id`                   | `ObjCId`      | (†)

    Objective-C  | 仓颉        | `T`是...                              | 备注
    ------------ | ------------   | ----------------------------------------- | ------
    `T*`         | `CPointer<T'>` | ... 基本数据类型或结构体类型         | -
    `T*`         | `CPointer<U'>` | ... 枚举类型且`U`是其底层类型 | -
    `T*`         | `CFunc<T'>`    | ... 纯 C 函数类型                | -
    `T*`         | `T'`           | ... Objective-C 类                          | (†)

    (\*) Objective-C 结构体禁止包含任何非`CType`兼容类型的字段。详情请参见[Objective-C 结构体](#objective-c-结构体类型)。

    (†) 对于可能持有或接受`nil`值的镜像类型或互操作类的形参类型、返回类型及局部变量等，请使用`Option<T'>`。详情请参见[由 Objective-C 到仓颉的映射关系](#由-objective-c-到仓颉的映射关系)章节。

**支持的特性：**

互操作类中的成员函数：

* 可以重写其父类中的方法。
* 可以实现其实现的接口中的方法。
* 可以新定义互操作类中独有的成员函数。

互操作类的构造函数和成员函数：

* 在函数体中，如果纯粹是在操作普通仓颉类型的值，那么实际上可以正常使用所有仓颉语言特性。
* 可以使用普通仓颉语法来：
    * 实例化互操作类和`@ObjCMirror`类。
    * 调用互操作类和`@ObjCMirror`类型的构造函数、实例/静态成员函数，包括通过`super`调用其父类的构造函数和成员函数。
    * 访问自己的成员属性，和访问其他互操作类和`@ObjCMirror`类型的非`private`成员属性。

**使用限制：**

* 互操作类可以实现`@ObjCMirror`接口，但禁止实现普通仓颉接口。

* 互操作类禁止被声明为`open`或`abstract`，且禁止被`extend`。

* 互操作类中的非`private`构造函数和成员函数：

    * 形参类型和返回类型只能为上述表中列举的 Objective-C 类型（由于变长参数要求使用仓颉`Array<T>`，而该类型并没有 Objective-C 映射类型，故变长参数并不支持）。
    * 禁止拥有命名形参。
    * 禁止拥有类型形参。

* 非`private`成员属性的类型只能为前文表中列举的 Objective-C 映射类型。

* 泛型 Objective-C 类型将被镜像为非泛型仓颉类型，详情请参见[Objective-C 泛型](#objective-c-泛型)。

* **重要限制：** 镜像类型和互操作类的实例，即 Objective-C 引用类型的值，禁止逃逸至仓颉全局变量、静态变量，以及任何能够在每次调用之间持久化的数据结构中。

**端到端示例（续）：**

继续上述的例子，开发者可能会如下实现互操作类`A`：

```cangjie
package cjworld           // Same package name

import interoplib.objc.*  // Always required

@ObjCImpl
public class A <: M {
    public init() {
        super()
    }

    @ForeignName["foo"]
    public override func foo(): Unit {
        println("Hello from overridden A.foo()")
    }

}
```

#### 步骤四：编译互操作类

执行以下命令行以编译互操作类：

```bash
cjc --target=arm64-apple-ios-simulator \
    --sysroot=$(xcrun --show-sdk-path --sdk iphonesimulator) \
    --output-type=dylib \
    --int-overflow=wrapping \
    <source-files> \
    -o <target-file> \
    --link-options "-undefined dynamic_lookup"
```

其中：

`<source-files>`是互操作类的源文件，以及各镜像类型定义的源文件。

`<target-file>`是得到的包含互操作类逻辑的动态库的文件名，例如`libcjworld.dylib`。

cjc 会同时自动生成 Objective-C 源文件（`.h`和`.m`文件），这些 Objective-C 源文件中包含有 Objective-C 包装类（对应互操作类）。这些源文件默认生成在`./objc-gen`子目录中。

需要为生成的动态库`.dylib`文件签名：

```bash
xcrun codesign --sign - <dylib-file>
```

**端到端示例（续）：**

首先编译互操作类源文件：

```bash
cd cjworld

cjc --target=arm64-apple-ios-simulator \
    --sysroot=$(xcrun --show-sdk-path --sdk iphonesimulator) \
    --output-type=dylib \
    --int-overflow=wrapping \
    *.cj \
    -o libcjworld.dylib \
    --link-options "-undefined dynamic_lookup"
```

cjc 将生成三个文件：`./libcjworld.dylib`、`./objc-gen/A.h`和`./objc-gen/A.m`。

然后为动态库签名：

```bash
xcrun codesign --sign - libcjworld.dylib
```

#### 步骤五：整合所有产物

* 在 XCode 项目中创建一个子目录，将`$CANGJIE_HOME/runtime/lib/ios_simulator_aarch64_cjnative/`目录下的所有动态库文件都拷贝一份到该目录下。

* 将这些动态库，以及[前一步骤](#步骤四编译互操作类)中得到的动态库添加进 XCode 项目依赖（“BuildPhases”标签页，添加进“Copy Files”和“Link Binary With Libraries”）。

* 将[前一步骤](#步骤四编译互操作类)中生成的`.h`和`.m`文件拷贝到项目根目录以参与编译构建。

接着重新构建项目即可。

**端到端示例（续）：**

在 XCode 工程的根目录创建一个子目录，将仓颉 SDK 中用于 iOS 的所有动态库文件全部拷贝到该目录下：

```bash
cd ..
mkdir -p CJRuntimeDylibs
cp $CANGJIE_HOME/runtime/lib/ios_simulator_aarch64_cjnative/*.dylib CJRuntimeDylibs/
```

将这些动态库以及`./cjworld/libcjworld.dylib`作为依赖添加进 XCode 工程，具体操作是，在“BuildPhases”中的“Copy Files”和“Link Binary With Libraries”列表中将它们添加进去。

将所有 cjc 生成的`.h`和`.m`文件放置到 XCode 工程根目录：

```bash
mv cjworld/objc-gen/*.h ./
mv cjworld/objc-gen/*.m ./
```

然后重新构建 XCode 工程。

### 在 Objective-C 侧调用仓颉

在[上一节](#从零实现互操作层)中开发者设计、实现并编译了互操作层，最后将互操作层集成进 XCode 工程。现在，开发者就可以在 Objective-C 侧实现对仓颉侧实现的逻辑的调用了。互操作类经 cjc 编译自动得到的 Objective-C 包装类可以直接由 Objective-C 代码调用使用，从而间接调用对应的互操作类的逻辑。

**端到端示例（续）：**

在 Objective-C 侧代码中，实例化类`A`，然后调用其`foo`实例方法，如下：

```objectivec
       .  .  .
#import "M.h"
#import "A.h"
       .  .  .
    M* a = [[A alloc] init];
    [a foo];
       .  .  .
```

重新构建 XCode 工程，然后直接在 iOS 模拟器上运行应用查看效果。

## 后续操作步骤

经过[上述操作流程](#从零实现互操作层)的讲解，现在应该已经明白了如何往互操作层中新增更多的互操作类，以及如何在互操作类中使用到更多的 Objective-C 类型，以下是对后续操作步骤的总结，开发者会发现其实依然对应着上述的五个操作步骤：

**[步骤一](#步骤一设计互操作层)：** 现在开发者可以根据设计，实现更多的互操作类，或者对现存的互操作类进行增强实现，比如实现新成员函数、成员属性等。

**[步骤二](#步骤二生成镜像类型)：** 如果开发者在修改互操作层的过程中识别到需要用到某些尚未被镜像的 Objective-C 类型，应该这么做：首先重新构建当前的 XCode 工程看看是否能够编译成功，确保代码的连贯性无问题；然后根据需要编辑镜像生成器配置文件，配置好后调用镜像生成器全量重新生成所有镜像。注意，推荐全量重新生成，以确保镜像代码的连贯性。

**[步骤三](#步骤三实现互操作类)：** 获得需要的全部 Objective-C 类型的镜像后，开发者就可以继续根据设计实现新的互操作类，或对现存互操作类进行翻修。

**[步骤四](#步骤四编译互操作类)：** 编译所有互操作类及其他相关源文件。

**[步骤五](#步骤五整合所有产物)：** 将上一步中 cjc 生成的`.h`、`.m`和`.dylib`文件拷贝到相应的位置，然后重新构建 XCode 工程。

接着，开发者就可以[在 Objective-C 侧使用](#在-objective-c-侧调用仓颉)刚刚新增的互操作类了。

### 互操作类的特性与限制

1. 互操作类必须是一个镜像类的直接子类。

2. 互操作类可以实现一到若干个镜像接口，但禁止实现任何普通仓颉接口。反之，普通仓颉类禁止实现镜像接口，普通仓颉接口也禁止继承镜像接口。

3. 互操作类禁止被声明为`open`或`abstract`，且禁止被`extend`。

4. 互操作类中可以定义新的实例成员变量，且变量类型可以是任何仓颉类型。互操作类中的成员函数可以对其父类中的成员方法进行重写。

5. 互操作类中可以定义构造函数，构造函数中可以通过`super()`调用父类的构造方法，且遵循普通仓颉构造函数中`super`和实例成员函数调用的顺序的相关规定，以及同样要求在构造函数中需要对所有无初始化器的实例成员变量初始化。

6. 互操作类中的实例成员函数体中，可以调用父类的实例方法，如果父类的实例方法在互操作类中被重写，也同样支持通过`super.`来调用。

7. 镜像类型和互操作类中定义的构造函数和成员函数的函数签名中所允许使用的类型必须是 (a) 镜像类型或互操作类 (b) 100%与 Objective-C 对应的基本数据类型。详情请参见上述的[步骤三](#步骤三实现互操作类)和[由 Objective-C 到仓颉的映射关系](#由-objective-c-到仓颉的映射关系)章节。

## 由 Objective-C 到仓颉的映射关系

当前版本的 Objective-C 镜像生成器遵循以下所描述的 Objective-C 到仓颉的类型映射规格。

### 一般注意事项

Objective-C 镜像生成器调用 clang 解析 Objective-C 源码，特别地，调用时会带有`-fobjc-arc`编译选项。

Objective-C 源码中，被标记为`unavailable`的声明将被忽略。

全局函数、文件作用域函数及变量声明也均将被忽略。

在输出的仓颉源文件中，所有声明的顺序保持与源 Objective-C 源文件中各声明在文件中的顺序一致，其中唯一的例外是嵌套类型定义。

### Objective-C 名称

原 Objective-C 标识符一般情况下都会被原样保留，除了以下这些情况：

* Objective-C 的标识符与仓颉关键字存在冲突，例如`catch`、`false`、`UInt32`等。冲突的标识符会在仓颉侧使用反引号` `` `包裹。

* Objective-C 允许定义一对同名的类和协议，而仓颉禁止同包中存在一对同名的类和接口。当 Objective-C 侧一对同名的类和协议同时被镜像时，由协议镜像得到的仓颉接口的名字，会在原协议的名称的基础上，加上`Protocol`后缀。

* Objective-C 允许定义一对同名的实例方法和静态方法，而仓颉禁止定义同名的实例成员函数和静态成员函数。当 Objective-C 侧存在同名的实例方法和静态方法，且它们将被镜像，那么最靠近冲突源的那个方法将会被重命名。如果导致冲突的实例方法和静态方法定义源于同一个类或协议中，静态方法将被重命名。重命名的方法是，对于实例方法，方法名加上`Instance`后缀，对于静态方法，方法名加上`Static`后缀。例如，在以下例子中：

    ```objc
    @interface A
    +(void)foo;
    @end

    @interface B : A
    -(void)foo;
    +(void)bar;
    -(void)bar;
    @end
    ```

    上述 Objective-C 类型将被镜像为：

    ```cangjie
    @ObjCMirror
    public open class A <: ObjCId {
        public static func foo()
    }

    @ObjCMirror
    public open class B <: A {
        public open func fooInstance()
        public static func barStatic()
        public open func bar()
    }
    ```

* 对于拥有不同方法名，但形参个数相同且形参类型分别相同的`init`方法，将无法被解析。

### Objective-C 类型别名

`typedef`声明将被映射为仓颉可见性`public`的类型别名。​

### Objective-C 基本数据类型

Objective-C 基本数据类型将被映射为对应的仓颉基本数据类型。对于各平台特定大小的 C 类型，将根据​host 平台（即运行镜像生成器本身的平台）上其长度来决定映射到哪个仓颉类型。例如，在 MacOS 上，该映射关系可能为：

| Objective-C          | 仓颉   |
| -------------------- | --------- |
| `void`               | `Unit`    |
| `BOOL`               | `Bool`    |
| `signed char`        | `Int8`    |
| `short`              | `Int16`   |
| `int`                | `Int32`   |
| `long`               | `Int64`   |
| `long long`          | `Int64`   |
| `unsigned char`      | `UInt8`   |
| `unsigned short`     | `UInt16`  |
| `unsigned int`       | `UInt32`  |
| `unsigned long`      | `UInt64`  |
| `unsigned long long` | `UInt64`  |
| `float`              | `Float32` |
| `double`             | `Float64` |

### Objective-C 结构体类型

如果一个 Objective-C `struct`中仅包含对于仓颉而言`CType`兼容的类型的字段，那么该 Objective-C `struct`将被映射为仓颉可见性`public`的`@C struct`类型。如果 Objective-C `struct`包含非`CType`兼容的类型的字段，例如 Objective-C 对象指针，当前不支持镜像。

嵌套的`struct`将被镜像为顶级仓颉`@C struct`，因为仓颉仅支持顶级类型定义。

不完全结构声明（用于前向声明，例如`struct MyRecord;`）将被镜像为空`struct`（`struct`类型定义中无任何成员）。

Objective-C `struct`的字段将被镜像为可见性`public`的成员变量。

仓颉不支持位域，如果原`struct`的字段带有位域，这些宽度信息将被忽略，且镜像生成器将告警。

与 Objective-C 不同，仓颉要求`struct`中所有成员变量都需要在构造时被初始化。因此，镜像得到的仓颉`struct`的所有成员变量都会带有零初始化器。例如：

```objectivec
struct A {
    int x;
    double y;
    BOOL z;
    struct A *w;
};
```

上述类型将被镜像为：

```cangjie
@C
public struct A {
    public var x: Int32 = 0
    public var y: Float64 = 0.0
    public var z: Bool = false
    public var w: CPointer<A> = CPointer<A>()
}
```

### Objective-C 枚举类型

C 枚举声明将被镜像为`abstract sealed class`，此处的`class`起到的是命名空间的作用。各枚举成员​将被镜像为`public static`成员变量，各成员变量初始化为各自对应的值。如果枚举声明显式指定了底层类型，则各成员变量的类型为该底层类型的镜像类型；否则，默认为`Int32`类型。

### Objective-C 联合体类型

仓颉不支持 C 的`union`类型，故其将被镜像为转换为仓颉`struct`，各原联合体中的成员依次被镜像为成员变量，这明显是不符合原联合体的语义的，故对此将输出告警信息。

### Objective-C 类和协议

Objective-C 类和协议将分别被镜像为仓颉类和接口。所有生成的镜像类和接口均实现了内置`ObjCId`镜像接口（见[内置类型](#objective-c-内置类型)）。

不支持变长参数，对于拥有变长参数的方法，`, ...`部分将被忽略。

Objective-C 方法的完整名称，即选择器，中可能包含有`:`，而仓颉标识符不支持含有`:`。这种方法名在镜像为仓颉函数名时，遵循以下转换规则：

* 直接跟随在`:`之后的那个字母（如果有）将被替换为大写。
* 所有`:`均将被删除。

原选择器则将被保留在仓颉侧`@ForeignName`注解中。

**示例：**

```objectivec
@interface A
- (void)foo;
- (void)foo:(int)i;
- (void)foo:(int)i bar:(int) j;
- (void)foo:(int)i bar:(int) j baz:(int) k;
@end
```

将被镜像为：

```cangjie
@ObjCMirror
public open class A {
    public open func foo(): Unit
    @ForeignName["foo:"] public open func foo(i: Int32): Unit
    @ForeignName["foo:bar:"] public open func fooBar(i: Int32, j: Int32): Unit
    @ForeignName["foo:bar:baz:"] public open func fooBarBaz(i: Int32, j: Int32, k: Int32): Unit
}
```

在仓颉中，成员属性的 getter/setter 函数的名称是固定的，而 Objective-C 则不然。因此，只有在条件允许的情况下，Objective-C 类或协议中的属性才会被镜像为仓颉成员属性。在条件不允许的情况下，Objective-C 属性的 getter/setter 将被镜像为仓颉实例成员函数。

Objective-C 实例变量将被镜像为仓颉实例成员变量。

`instancetype`将被镜像为当前类型声明的类型名。

#### Objective-C 类

Objective-C 的`@interface`类声明将被镜像为仓颉的`@ObjCMirror public open class`。

Objective-C 的`@interface`的分类（category）和扩展（extension）声明的镜像均将被直接融合进相应的仓颉类定义中。

Objective-C 的`@implementation`声明将被忽略。

类的前向声明（`@class`标记）被镜像为空的仓颉类定义（即类中无任何成员）。

仓颉存在构造函数和非构造函数的成员函数之间的区分，而 Objective-C 则并没有直接的“构造方法”和“非构造方法”的区分。被归类为`init`方法的方法，将被镜像为仓颉构造函数，且存在以下两个限制：

* Objective-C 类中，如果两个`init`方法的方法签名仅仅区别于选择器的名称，即，两个方法的形参个数相同，且对应的形参类型相同，那么镜像生成器将把这两个方法所镜像得到的两个构造函数声明注释掉，并输出告警表明存在冲突。

* `init`方法与其他方法一样能够被继承，而在仓颉中，构造函数是不会被继承的。因此，在镜像类或互操作类的实例化过程中，其父类的`init`方法镜像得到的构造函数将无法被调用。

其他 Objective-C 类的方法将被镜像为仓颉类的`public open`成员函数。实例方法将被镜像为实例成员函数，类方法将被镜像为静态成员函数。

#### Objective-C 协议

Objective-C 的`@protocol`将被镜像为仓颉的`@ObjCMirror public interface`。

协议的前向声明被镜像为空的仓颉接口定义（即接口中无任何成员）。

Objective-C 协议的方法将被镜像为仓颉接口的`public open`成员函数。实例方法将被镜像为实例成员函数，类方法将被镜像为静态成员函数。

`@optional`指令将被忽略。

### Objective-C 指针类型

Objective-C 指针类型的`const`、`volatile`和`restrict`修饰符均将被忽略。

C 基本数据类型`T`的指针及其类型别名将被镜像为相应的`CPointer<T'>`，其中`T'`是`T`的镜像类型（详情请参考[Objective-C 基本数据类型](#objective-c-基本数据类型)）。

底层类型为`T`的 C 枚举类型的指针将被镜像为`CPointer<T'>`，其中`T'`是`T`的镜像类型，原枚举类型名将在注释中体现。

#### Objective-C 结构体指针类型

对于 Objective-C 结构体指针类型，如果 C 结构体`T`是`CType`兼容的，则将被镜像为`CPointer<T'>`，其中`T'`是`T`的镜像类型；否则将被镜像为`ObjCPointer<T'>`（该类型名为暂定名）。`ObjCPointer`类型定义在互操作库中。

#### Objective-C 函数指针类型

对于 Objective-C 函数指针类型，如果函数形参和返回类型均为`CType`兼容类型，则将被镜像为`CFunc<F>`；否则将被镜像为`ObjCFunc<F>`（该类型名为暂定名）。`ObjCFunc`类型定义在互操作库中。

#### Objective-C 块指针类型

Objective-C 块指针类型将被镜像为`ObjCBlock<F>`（该类型名为暂定名）。`ObjCBlock`类型定义在互操作库中。`ObjCBlock<F>`中的类型形参`F`是相应的仓颉函数类型。

#### Objective-C 对象指针类型

指向 Objective-C 类实例的指针类型将按照以下规则进行镜像：

* Objective-C 类实例的指针（形如`SomeClass*`）类型将被镜像为该类的镜像类型`@ObjCMirror class`。

* Objective-C 带有有且只有一个协议约束的`id`类型（例如`id<NSCopying>`）将被镜像为该协议的镜像类型`@ObjCMirror interface`。

* Objective-C 带有多于一个协议约束的`id`类型（例如`id<NSCopying, NSSecureCoding>`）将被镜像为纯粹的`ObjCId`类型，而各协议则将被列举在生成的注释中。`ObjCId`接口类型定义于互操作库，所有`@ObjCMirror`类和接口均实现或继承该接口。

* 如果在泛型模板中使用的一个泛型类型形参指定有单个约束协议，该类型形参在使用处将被替换为协议类型的引用类型，原类型形参名将被留存在注释中。

### Objective-C 泛型

泛型 Objective-C 类将被镜像为非泛型仓颉类。原 Objective-C 的轻量级泛型的信息，例如“`<T>`”、“`<Foo>`”将被保存在生成的仓颉类旁边的注释中。类定义中的所有泛型使用均将被替换为`ObjCId`。

**示例：**

```objectivec
@interface G<T> : NSObject
- (void)f:(T)t;
@end
```

以上类型将被镜像为：

```cangjie
@ObjCMirror
public open class G/*<T>*/ <: NSObject {
    @ForeignName["f:"] public open func f(t: ?ObjCId /*T*/): Unit
}
```

注意，在当前版本，泛型约束将被忽略，例如：

```objectivec
@interface G<T: SomeType*> : NSObject
- (void)f:(T)t;
@end
```

以上类型的镜像结果将与上一个的镜像结果完全一致。

### Objective-C 内置类型

镜像生成器在生成镜像时会假设以下仓颉类型已被定义在互操作库中，生成的镜像中将用到这些类型，用户亦可使用这些类型。当前版本中，部分类型尚未实现完全，且未来版本中这些类型的名称可能会改变。

| Objective-C         | 仓颉 (\*)        | 备注                                           |
| ------------------- | ------------------- | ----------------------------------------------------- |
| `id`                | `ObjCId`            | 所有`@ObjCMirror`类和接口均实现该`@ObjCMirror`接口，其对应 Objective-C 的`id` |
| `SEL`               | `SEL`?              | 该`class`对应 Objective-C 的`SEL`                     |
| `Class`             | `Class`?            | 该`class`对应 Objective-C 的`Class`                   |
| `Protocol`          | `Protocol`?         | 该`class`对应 Objective-C 的`Protocol`                |
| 指针类型        | `ObjCPointer<T>`?   | 该`struct`对应 Objective-C 的`T`为非`CType`兼容的 C 结构体 |
| non-C function type | `ObjCFunc<F>`?      | 该类型用于 C 函数指针类型中包含有非`CType`兼容类型，`F`是仓颉函数类型 |
| 块类型          | `ObjCBlock<F>`?     | 该`struct`对应 Objective-C 的块类型，其中`F`是仓颉函数类型 |
|                     | `__builtin_va_list` | `CPointer<Unit>`的辅助用类型别名，用于当前版本镜像生成器的实现，但在未来版本中将被移除 |

(\*) 这些仓颉类型名称均为暂定的，未来版本中可能改变。

## 尚未实现的特性

仓颉 SDK 对 Objective-C 互操作的支持尚在开发中，某些特性尚未实现，某些则可能在首个正式发布版本前发生变化，某些由于仓颉与 Objective-C 之间的根本差异完全无法，或部分无法被实现。

* C 语言中存在若干特性，比如能改变数据默认大小、打包方式、填充规则和/或对齐方式，这些特性与 ABI 高度相关。仓颉并不支持如此底层的控制，特别是位域。镜像生成器将直接忽略位域宽度指定符，并输出相应告警信息。

* 仓颉的 C 互操作不支持 C 的`union`类型，故`union`将被镜像为仓颉`struct`类型，且镜像生成器将告警。

* 如果 Objective-C 的`struct`中存在类型非`CType`兼容的字段，则该`struct`无法被镜像。

* 匿名 C 枚举声明将被忽略，具名 C 枚举声明则将被镜像为`abstract sealed class`。详情请参见[Objective-C 枚举](#objective-c-枚举类型)小节。

* 不支持对变长参数，但拥有变长参数的方法依然也支持镜像，不过变长参数的方法中的`...`将被忽略。

* `@optional`标注将被忽略。

* Objective-C 属性在条件允许时才会被镜像为仓颉成员属性，否则其 getter/setter 方法将被视作普通的实例方法，并被镜像为仓颉实例成员函数。详情请参见[Objective-C 类和协议](#objective-c-类和协议)小节。

* 修饰符`const`、`volatile`、`restrict`均将被忽略。

* Objective-C 中名称为`init`的方法将被镜像为仓颉的构造函数，且存在以下两方面的限制：

    * 在一个仓颉类中，两个构造函数即便各形参名称不尽相同，但只要函数签名相同，就禁止同时存在；而在 Objective-C 中，同名为`init`的方法，却可以通过外部参数名进行区分。

    * 仓颉类中的构造函数不会被继承，而 Objective-C 中并没有专门的“构造方法”，而只有名为`init`的方法，而所有方法都可以被继承。

    详情请参见[Objective-C 类](#objective-c-类)章节。

* 泛型 Objective-C 类将被镜像为非泛型仓颉类，详情请参见[Objective-C 泛型](#objective-c-泛型)章节。

* 对`@protocol`的镜像支持尚未完全支持。

* 当前尚不支持对拥有非`CType`兼容类型作为形参/返回类型的函数指针类型进行镜像。

* 当前尚不支持 Objective-C 块。

* 尚未实现 Objective-C 类型`NSString`与仓颉类型`String`之间相互转换的内在函数。

## Objective-C 侧 nil 值处理

仓颉无`nil`引用的概念，因此对于 Objective-C 的`nil`值不存在等价物。对于 Objective-C 侧的类和协议类型镜像为仓颉类和接口类型的实例的指针，从 Objective-C 侧传入到仓颉侧后，如果为`nil`，则会导致仓颉侧的段错误。反之，仓颉侧也不存在直接往 Objective-C 侧返回`nil`值的途径。

因此决定将仓颉`Option<T>`枚举用于表示这类 Objective-C 类型，其中`None`表示`nil`值，而`Some(r)`表示一个非空引用值`r`。假设仓颉类型`T`是`@ObjCMirror`镜像类型或`@ObjCImpl`互操作类，cjc 将把`Option<T>`判定为 Objective-C 兼容类型，并对该类型的值进行装包/拆包。

示例如下，以下`@interface`：

```objectivec
@interface MyContainer: NSObject
   .  .  .
- (void)addItem:(MyItem *)item withUuid:(NSString *)uuid;
- (MyItem *)itemWithUuid:(NSString *)uuid;
- (NSString *)uuidForItem:(MyItem *)item;
@property (copy) NSArray<MyItem *> *allItems;
@end
```

将被镜像为：（注意，以下代码出于简洁考虑省略了`@ForeignName`注解）

```cangjie
@ObjCMirror
open class MyContainer <: NSObject {
       .  .  .
    public open func addItemWithUuid(item: ?MyItem, uuid: ?NSString): Unit
    public open func itemWithUuid(uuid: ?NSString): ?MyItem
    public open func uuidForItem:(item: ?MyItem): ?NSString
    public mut prop allItems ?NSArray/*<MyItem>*/
}
```

上述`Option<T>`装包确保了即便 Objective-C 侧往仓颉侧传入`nil`值，仓颉侧不会因此崩溃，但这个解决方法不可避免地带来了部分性能和内存足迹的劣化。解决方法引入的另一个缺点是[型变的丢失](#型变丢失)。不过，[Objective-C 对可空性注解的支持](#objective-c-可空性注解)显著消减了上述由于引用封装所带来的影响。

> **注意：**
>
> 上述问题对于能够被映射为仓颉`CPointer<T>`类型的 C 类型并不构成麻烦，因为`CPointer<T>`类型实现内部提供有相关的空指针检查功能。

### 型变丢失

为 Objective-C 镜像类型和互操作类进行[`Option<T>`装包](#objective-c-侧-nil-值处理)带来了一个显著的限制：向这样装包的类型在所有其他方面均完全遵循仓颉语义规则。具体而言，根据仓颉语义规则，`Option<T>`对其类型变元`T`是**不变**的，换句话说，对于两个类型`U`和`T`，除非`U`和`T`是相同的类型，否则即便`U`是`T`的子类型，`Option<U>`也与`Option<T>`不存在任何子类型关系。这意味着，对于镜像类型中存在重写关系的方法，如果这两个方法的返回类型存在**协变**的关系，这个协变的关系无法在仓颉侧保留下来，子类中的重写方法的返回类型的镜像必须改为父类中方法的返回类型的镜像。

示例如下，在以下代码片段中，Objective-C 类`Foo`是类`Bar`的直接父类：

```objectivec
@interface Foo : NSObject
@end

@interface Bar : Foo
@end
```

Objective-C 类`C`中声明有方法`get`，其返回类型为`Foo`：

```objectivec
@interface C : NSObject
- (Foo*) get;
@end
```

Objective-C 类`D`继承`C`，其中重写了方法`get`，返回类型换为了更加精确的类型`Bar`：

```objectivec
@interface D : C
- (Bar*) get;
@end
```

假设不存在`Option<T>`装包，上述所有类型将被镜像为：

```cangjie
@ObjCMirror
open class Foo <: NSObject {}

@ObjCMirror
open class Bar <: Foo {}

@ObjCMirror
open class C <: NSObject {
    open func get(): Foo
}

@ObjCMirror
open class D <: C {
    open func get(): Bar       // Return type covariance in action
}
```

但正如前文所说，如果`get`方法存在返回`nil`的可能性，那么仓颉侧将不可避免地崩溃。

如果进行`Option<T>`装包，就可以解决`nil`的问题，不过所有重写的成员函数的返回类型就不得不降级为原始的（定义在父类型中的）成员函数的返回类型：

```cangjie
@ObjCMirror
open class Foo <: NSObject {}

@ObjCMirror
open class Bar <: Foo {}

@ObjCMirror
open class C <: NSObject {
    open func get(): Option<Foo>
}

@ObjCMirror
open class D <: C {
    // open func get(): Option<Bar>  // Error, `Option<T>` is not covariant by T
    open func get(): Option<Foo>     // OK, but the return type is lowered
}
```

[Objective-C 可空性注解](#objective-c-可空性注解)一定程度上消减了该问题。

### Objective-C 可空性注解

XCode6.3 开始支持 Objective-C 的可空性注解，其目的是更好地与新 iOS/OSX 开发语言 Swift 集成配合，Swift 本身将调用 Objective-C 所提供的 API。

> **Objective-C 可空性标注：**
>
> 关键字`nullable`、`nonnull`可用于注修饰 Objective-C 属性、方法形参类型和返回类型。它们的含义分别是指定的实体可能/不可能持有或接受`nil`值。除此之外还有关键字`null_unspecified`，意思是并不确定指定的实体到底是可能还是不可能持有或接受`nil`值，不过该关键字及其少见被使用到。
>
> 另外，指针类型也可以被`_Nullable`、`_Nonnull`注解，与上述各关键字的语义相同。
>
> Objective-C 属性也可以被指定为`null_resettable`，语义是该属性的 getter 不可能返回`nil`值，而如果调用 setter 时传入`nil`值，该属性将被重置为某默认值。

因此，如果某处对 Objective-C 引用类型的使用被标记为不可为空（例如被`nonnull`标记），则该使用处将被免去`Option<T>`装包。换句话说，镜像生成器只会为所有未被`nonnull`或`_Nonnull`注解的成员属性类型、成员函数形参类型和成员函数返回类型进行`Option<T>`装包。

现在，请重新考虑[上一节中](#objective-c-侧-nil-值处理)的例子，这次我们对其添加了可空性注解，如下：

```objectivec
@interface MyContainer: NSObject
   .  .  .
- (void)addItem:(nonnull MyItem *)item withUuid:(nonnull NSString *)uuid;
- (nullable MyItem *)itemWithUuid:(nonnull NSString *)uuid;
- (nullable NSString *)uuidForItem:(nonnull MyItem *)item;
@property (copy, nonnull) NSArray<MyItem *> *allItems;
@end
```

镜像生成器将不对`nonnull`实体进行`Option<T>`装包：（注意，以下代码出于简洁考虑省略了`@ForeignName`注解）

```cangjie
@ObjCMirror
open class MyContainer <: NSObject {
       .  .  .
    public open fund addItemWithUuid(item: MyItem, uuid: NSString): Unit
    public open func itemWithUuid(uuid: NSString): ?MyItem
    public open func uuidForItem:(item: MyItem): ?NSString
    public open prop allItems: NSArray
}
```

> **注意：**
>
> 当前尚不支持正确地将 Objective-C 属性的`null_resettable`的语义传播至仓颉成员属性，故该注解将被视作`nullable`处理。

**如果开发者的 Objective-C 代码尚未采用上述的可空性注解，我们推荐开发者在开始进行互操作层设计与实现前，事先为互操作层相关的 Objective-C 代码合理添加`nonnull`注解**。因为这样之后可能将显著减少镜像类型中的`Option<T>`装包，从而使得互操作层更加清晰已读。

## Objective-C 镜像生成器参考

### 准备工作

在使用镜像生成器前请确保已执行仓颉 SDK 中的`envsetup.sh`脚本。

开发者需要知道将要为之生成镜像的所有类型所依赖的类型所在的头文件的本地路径。这包括 iOS 标准库头文件，以及所有 XCode 在构建项目时 Objective-C 编译器的所有头文件搜索路径。

### 命令行使用方法

`ObjCInteropGen [-v] [--mode=normal`_`config-file`_`]`

`-v`

生成

`--mode=normal`

强制使用正常模式。除正常模式外的其他模式均仅用于镜像生成器本身内部开发和测试。在当前版本，如果指定了`config-file`，那么必须指定`--mode=normal`。在未来版本中，该选项将变为可选。

_`config-file`_

配置文件的路径。

### Objective-C 镜像生成器配置文件语法

Objective-C 镜像生成器配置文件是一个纯文本文件，遵循 TOML 语法，其中指定了以下配置信息：

* 将生成的镜像源文件保存在哪个目录下。
* 源 Objective-C 头文件名（`.h`文件）。
* 生成的仓颉包的包名，以及将生成的哪些镜像类型放置在哪个仓颉包中。
* 对于部分开发者需要特殊处理的类型，需要将类型进行如何的映射。

对于配置文件中将被视作正则表达式的字符串，必须遵循 ECMAScript 正则表达式语法。

#### 输出根目录

`[output-roots]`表的每个子表键定义了一个目录标签，这个目录标签对应了本地文件系统中的一个路径，这个路径定义于子表中的`path`配置项。[`[[packages]]`数组](#镜像生成器单包配置)中的`output-root`配置项将被指定一个目标标签，该目录标签对应的本地文件系统路径将被作为根目录，该`[[packages]]`相应包下生成的镜像源文件均将相对于该根目录放置。
7
**示例：**

```toml
[output-roots.lib]
path = "./lib/src"

[output-roots.app]
path = "./main/src"

[[packages]]
package-name = "com.vendor1.lib1"
output-root = "lib"  ## Output to "./lib/src/com/vendor1/lib1"
filters = ...

[[packages]]
package-name = "com.vendor2.lib2"
output-root = "lib"  ## Output to "./lib/src/com/vendor2/lib2"
filters = ...

[[packages]]
package-name = "com.mycompany.app"
output-root = "app"  ## Output to "./main/src/com/mycompany/app"
filters = ...
```

#### 头文件输入

`[sources]`表的每个子表键定义了一组独立的头文件，镜像生成器将确保将这些头文件作为输入。

**该表支持以下配置项：**

`paths` (必选)

字符串数组，每个字符串是单个头文件的路径，镜像生成器将确保读取这些头文件。

`arguments` (可选)

字符串数组，保存有一系列 clang 编译选项，当镜像生成器处理列举在`paths`中的源文件时，将作为 clang 的命令行参数传入。

**示例：**

```toml
[sources.all]
paths = ["original-objc/M.h"]
```

#### 额外的 clang 命令行参数

`[sources-mixins]`表中的每个表项是个表，每个表首先通过`sources`属性的正则表达式匹配[`[sources]`表](#头文件输入)中的一到若干个表键，匹配到的这些表键所对应的头文件在被 clang 处理时，将额外指定命令行参数。

**支持的属性：**

`sources` （必选）

正则表达式字符串，用于匹配头文件名。

`arguments-prepend`
`arguments-append` （可选）

字符串数组，内容将被用于作为额外的 clang 命令行参数。`arguments-prepend`和`arguments-append`中的命令行参数将被分别插入到相应`[sources]`表项的`arguments`属性的数组的前和后。

**示例：**

```toml
[sources.UIWidgets]
paths = ["objc/UIWidgets.h"]
arguments = [ "-I", "/usr/local/include/share/Widgets" ]

[sources.UIPanels]
paths = ["objc/UIPanels.h"]
arguments = [ "-I", "/usr/local/include/share/Panels" ]

[sources-mixins.UI]
## Add these Clang arguments for both UIWidgets and UIPanels
sources = ["UI.+"]
arguments-append = [
    "-I", "/usr/local/include/Frameworks/AcmeUI"
]
```

#### 镜像生成器单包配置

`[[packages]]`数组的每个表项指定了一个目标仓颉包名，一组名称过滤器，用于说明哪些 Objective-C 实体将被镜像到该仓颉包中，以及可选的，该包的输出目录。

**支持以下配置项：**

`package-name` （必选）

字符串，目标仓颉包的名称。

`output-path` （可选）

字符串，值为文件系统的路径（绝对路径或相对路径均可），该仓颉包的镜像文件均将被输出到该目录下。如果该路径中存在任何不存在的目录，镜像生成器将尝试创建它们。

`output-root` （可选）

字符串，值为[`[output-roots]`表](#输出根目录)中的子表键，也就是一个目录标签。该目录标签对应一个输出根目录，基于这个根目录，目标仓颉包的包名将作为子目录名，包名中的点`.`被替换为路径分隔符`/`，得到的路径将与`output-path`配置同等效果。

如果`output-root`未配置，且`[output-roots]`中有且只有一个子表键，该子表键对应的输出根目录将被采用；否则镜像生成器将报错。

**示例：**

```toml
[output-roots.main]
path="./cj-mirrors"

[[packages]]
package-name = "objc.foundation"
output-root = "main"
```

输出文件将置于`./cj-mirrors/objc/foundation`目录下。

`filters` （必选）

一个表，指定了一组名称过滤器，说明了需要确保源文件中的哪些 Objective-C 实体声明镜像到指定的仓颉包中。详情请参见[名称过滤器](#名称过滤器)。

**示例：**

```toml
## The Foundation framework
[[packages]]
package-name = "objc.foundation"
filters = { include = "NS.+" }
```

##### 名称过滤器

一个名称过滤器是一个 TOML 表，表中包含：

* `include`、`exclude`、`union`、`intersect`和`not`其中之一选一个作为属性。
* 可选的`filter`属性和/或`filter-not`属性。

以下将对各属性进行详细解释。

`include`

该属性值可以是一个正则表达式字符串，或一个数组中包含若干正则表达式字符串。如果值为单个正则表达式，只有匹配该正则表达式的类型名将被采纳。如果是正则表达式的数组，类型名匹配其中任一正则表达式即可被采纳。

**示例：**

```toml
## Only include entities that names of which start with "NS":
filters = { include = "NS.+" }

## Only include entities with names that either start with "Foo"
## or end with "Bar":
filters = { include = ["Foo.*", ".*Bar"] }
```

`exclude`

与`include`相反（见上文）如果一个类型名能够被`include`过滤器采纳，那么他就不会被`exclude`采纳；反之亦然。

**示例：**

```toml
## Include everything but entities the names of which start with "INTERNAL_":
filters = { exclude = "INTERNAL_.+" }
```

`union`

该属性用于结合两个以上的过滤器。其值为过滤器的数组，类型名只需要被其中任一过滤器采纳，就将被`union`过滤器采纳。

**示例：**

```toml
## An equivalent of the second `include` example above:
filters = { union = [ { include = "Foo.*" }, { include = ".*Bar" } ] }
```

`intersect`

该属性用于结合两个以上的过滤器。其值为过滤器的数组，类型名必须被其中所有过滤器采纳，才会被`intersect`过滤器采纳。

**示例：**

```toml
## Adding a negative filter:
filters = { intersect = [ { include = "NS.+" },
                          { exclude = "NSAccidentalClash" } ] }
```

`not`

该属性用于反转一个过滤器的含义，其值为单个过滤器。

**示例：**

```toml
## Another way to add a negative filter:
filters = { intersect = [ { include = "NS.+" },
                          { not = { include = "NSAccidentalClash" } } ] }
```

`filter`
`filter-not` （可选）

这两个属性必须与上述其他属性一起使用，即它们不能是`filters`表中的唯一属性。该属性值可以是一个正则表达式字符串，或一个数组中包含若干正则表达式字符串，其语义与`include`和`exclude`属性完全一致。

`filter`和`filter-not`用于在主过滤器已经过滤得到的所有类型名的基础上，进一步缩减成功匹配的类型名。对于`filter`，只有成功匹配其中任一正则表达式的类型名将被采纳；对于`filter-not`，只有不匹配其中任何正则表达式的类型名将被采纳。

`filter`和`filter-not`其实是`intersect`分别配合`include`和`exclude`操作的简写形式。

**示例：**

```toml
## Without filter-not:
filters = { intersect = [ { include = "NS.+" },
                          { exclude = "NSAccidentalClash" } ] }
## With filter-not:
filters = { include = "NS.+", filter-not = "NSAccidentalClash" }

## 'filter' and 'filter-not' can be used together:
filters = { include    = ".*Fizz.+",
            filter     = ".+Buzz.*",
            filter-not = ".*FizzBuzz.*" }
```

#### 类型名映射替换

`[[mappings]]`是一个表的数组，每个表中表示的类型名映射替换关系，最终会被统一收集为一个映射替换表，用于镜像生成过程中，将表中指定的若干类型名称替换为其他类型名。除了 C 的基本数据类型（例如`int`），几乎所有其他 Objective-C 类型均可通过此配置实现类型名的替换。

**示例：**

```toml
## Replace the type id, the root of the Objective-C type hierarchy,
## with NSObjectProtocol everywhere.
[[mappings]]
id = "NSObjectProtocol"
```

#### 导入其他配置文件

`imports`配置项的值是一个字符串数组，每个字符串是其他配置文件的文件路径，该配置文件中的配置信息将被添加进当前配置文件中。被导入的配置文件中的`packages`和`mappings`条目配置项中的配置信息将被追加到当前配置文件中。

支持配置文件的嵌套导入，但如果检测到配置文件的循环依赖导入则将导致编译器报错。

**使用示例:**

```toml
import = "../common.toml"
```
