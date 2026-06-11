# 仓颉-Objective-C 互操作

**注意：** Objective-C 互操作特性为实验性功能，仍在持续改进中。

**注意：** 请优先查阅英文版本文档。

## 简介

**仓颉多平台**技术使仓颉开发者能够将代码集成到新的 Android/iOS 应用中，或逐步用仓颉代码替换现有应用中的 Java/Objective-C 部分。实现跨语言、跨运行时互操作的核心机制是*[镜像类型](#镜像类型)*，它将一种语言的类型暴露给另一种语言。

在仓颉侧，镜像类型支持以常规仓颉语法继承 Java/Objective-C 类并重写方法，以及实现 Java 接口和 Objective-C 协议。那些扩展或实现镜像类与接口/协议的仓颉类，会作为相应平台原生语言的类暴露回 Java/Objective-C。这使得应用的 Java/Objective-C 部分与仓颉部分能够无缝衔接，包括在仓颉代码中使用目标操作系统的 API。

### 挑战与解决方法

Java、Objective-C 和仓颉都是支持继承与多态的面向对象语言，但它们在语义、对象模型和执行模型上的差异，使得无法直接在 Java 或 Objective-C 代码中使用仓颉对象，反之亦然。

三种语言都拥有支持自动内存管理、线程、异常处理等底层能力的托管运行时，但实现方式各不相同。若让两套独立设计的复杂语言运行时彼此感知，可能使整个系统的复杂度超出可理解范围。

相反，仓颉与 Objective-C 的互操作通过将双方都伪装成更低级的 C 语言来实现。Objective-C 运行时模块 API 专为在 Objective-C 与其他语言之间创建桥接层而设计，提供丰富但低层的 C API；手动编写桥接代码众所周知十分繁琐，所幸 CJMP 将这类复杂性自动化处理。

同样，在 Android 上，应用的仓颉部分与 Java 部分通过 Java 本地接口（JNI）相互可见。JNI 最初用于在 C/C++ 等语言中编写 Java `native` 方法；与 Objective-C 运行时一样，CJMP 负责处理繁琐部分。

## 关键概念

### 镜像类型

将仓颉与 Objective-C 视为一对互操作语言时，仓颉中定义的镜像类型 _`T'`_ 表示已有的 Objective-C 类型 _`T`_，使第一种语言编写的代码能够使用该类型（可能有一定限制）。

两种语言中本质相同的布尔类型与数值类型会自然互为镜像：Objective-C 类型 `int` 的仓颉镜像类型是 `Int32`，依此类推。仓颉本身不支持的数值类型目前无法镜像，例如 Objective-C 类型 `int128_t` 无法镜像为仓颉基本类型。

对于类或协议等用户定义类型，镜像类型取另一种语言中最接近的等价物。例如，Objective-C 协议与仓颉接口非常相似。

镜像类型暴露原用户定义类型中可访问且能在另一种语言中使用的成员与构造函数；因此，返回 `int128_t` 的 Objective-C 方法无法镜像到仓颉。

通常可使用 iOS 版仓颉 SDK 附带的独立[镜像生成器](#objective-c-镜像生成器参考)，自动获得要在仓颉中使用的 Objective-C 类型的镜像类型定义。

#### 将 Objective-C 类型镜像为仓颉

`cjc` 编译器会将 Objective-C 镜像类型的使用替换为相应桥接代码，因此重要的是类型名称及其可访问成员的名称与类型。Objective-C 类型的镜像只包含成员声明：构造函数与成员函数/属性无函数体，成员变量无初始化器；`@private` 成员亦被省略。

为使这一仓颉语法扩展生效，每个镜像类型须标注 `@ObjCMirror`，以便编译器区分镜像类型声明与普通仓颉类型定义。

例如，以下 Objective-C 类的镜像类：

```objectivec
@interface Node : NSObject {
}
- (id)initWith:(int)x;
- (int)getX;
@end
```

可能看起来像这样：

```cangjie
@ObjCMirror
public open class Node <: NSObject {
    @ForeignName["initWith:"]
    public init(x: Int32)
    public open func getX(): Int32
}
```

### 镜像函数

Objective-C 与仓颉均支持不属于任何其他类型的顶级全局函数；这类 Objective-C 函数以_镜像函数_形式暴露给仓颉，本质上是自动生成的桥接代码，用于在语言间传递控制与数据。

### 互操作类

_互操作类_本质上是派生自一个或多个[镜像类型](#镜像类型)的仓颉类，且可从 Objective-C 使用。其所有构造函数与非继承的 `public` 成员函数通过 `cjc` 自动生成的_包装类_暴露给 Objective-C；包装类本身不定义其他可由用户调用的方法或构造函数，但从超类型继承的方法可在 Objective-C 与仓颉代码中调用。

例如，编译以下 Objective-C 互操作类时：

```cangjie
@ObjCImpl
public class BooleanNode <: Node {
    private let _flag: Bool
    public init(x: Int32, flag: Bool) {
        super.init(x)
        this._flag = flag
    }
    public func isFlagged(): Bool {
        _flag
    }
}
```

`cjc` 编译器还将生成一对类似于以下的 Objective-C 源文件：

```objectivec
// BooleanNode.h
@interface BooleanNode : Node
/* 胶水代码 */
- (id)init:(int32_t)x:(BOOL)flag;
- (BOOL)isFlagged;
/* 更多胶水代码 */
@end
```

```objectivec
// BooleanNode.m
@implementation BooleanNode : Node
/* 胶水代码 */
- (id)init:(int32_t)x:(BOOL)flag {
    /* 桥接代码，构造仓颉 BooleanNode(x, flag) 实例，
     * 并将其与正在构造的 Objective-C 实例（即 'self'）关联。
     */
}
- (BOOL)isFlagged {
    /* 桥接代码，调用与 'self' 关联的仓颉 BooleanNode 实例的
     * 'isFlagged' 成员函数，并返回结果。
     */
}
/* 更多胶水代码 */
@end
```

此后，Objective-C 与仓颉代码均可实例化互操作类 `BooleanNode`，调用其 `public` 实例成员函数 `getX()`（继承自 Objective-C 类 `Node`）和 `isFlagged()`，并将实例分别转换为 `Node` 及其镜像类型等。

### 外部类型

[镜像类型](#镜像类型)与[互操作类](#互操作类)并非在其定义语言中完全“原生”。类比而言，它们分别像临时访客与工作签证持有者，本文统称为_外部类型_。

### Objective-C 兼容类型

以下仓颉类型称为_Objective-C 兼容_类型：

* 与 Objective-C 基本类型直接对应的值类型（包含 `Int16`，但不包含 `Float16`）；
* [外部类型](#外部类型)；
* 形如 `Option<`_`T`_`>` 的类型，其中 _`T`_ 为[外部类型](#外部类型)（理由见 [_`null` 处理_](#nil-处理)）；
* [内置 `ObjC*`-类型](#内置类型) `ObjCPointer<T>`、`ObjCFunc<F>`、`ObjCBlock<F>`；
* `@C` struct；
* `CFunc<F>` 函数类型；
* `CString`；以及
* `Unit`（仅作为函数返回值类型）。

**重要提示：** 当前版本中，类型 `CPointer<T>` 与 `VArray<T,$N>` 本身_不是_ Objective-C 兼容类型，但这并不限制它们在 `@C` struct 或 `CFunc<F>` 函数类型中的使用。

## 在仓颉中使用 Objective-C

要实现 iOS 应用程序的 Objective-C 和仓颉部分之间的互操作，需要执行以下步骤：

1. 按照 Objective-C 类和方法来设计互操作层。

   开发者 → `interop layer design`（Objective-C 伪代码）

2. 为互操作层设计中使用的任何 Objective-C 类和协议生成镜像声明。

   `.h` → 镜像生成器 → `.cj`（镜像）

3. 用仓颉编写构成互操作层的类。根据需要使用的镜像 Objective-C 类型：创建实例、调用成员函数等。

   `interop layer design` + `.cj`（镜像） → 开发者 → `.cj`（互操作层）

4. 使用 `cjc` 一起编译互操作类和镜像类型。`cjc` 将生成：

   * 所有镜像类型使用的必要胶水代码。
   * 互操作层 Objective-C 部分的实际 Objective-C 源代码（即互操作类的 Objective-C _包装器_）。

   `.cj`（镜像 + 互操作层） → `cjc` → `.dylib` + `.h`/`.m`（互操作层）

5. 添加到 iOS 项目：

   * `cjc` 生成的 `.h` 和 `.m` 文件
   * `cjc` 生成的 `.dylib` 文件
   * 来自仓颉 SDK 的运行时库（`.dylib`）

   iOS 项目 + `.h`、`.m`、`.dylib` → iOS 工具链 → iOS 应用

6. 现在可以在应用程序的 Objective-C 代码中使用互操作类包装器，从而从 Objective-C 调用仓颉代码。

### 初始互操作类创建工作流

#### 步骤 1：设计互操作层

本步骤从 Objective-C 代码视角设计一个或多个互操作类的 API。对每个互操作类，需确定：

* 将扩展哪个 Objective-C 类，例如 `NSObject`；
* 将实现哪些 Objective-C 协议（如有）；
* 将具有哪些 `public`/`protected` 方法及/或构造函数（本步骤仅需确定参数类型、方法名与返回类型；实现将在仓颉中编写）。

另请参见[互操作类的特性与限制](#互操作类的特性与限制)。

对应用的 Objective-C 部分而言，互操作层与一组常规 Objective-C 类无法区分。因此可以 Objective-C 伪代码形式进行设计：写下各 Objective-C 类的规格与 `@interface` 定义。**注意：** 无需编写相应的 `@implementation` 部分，因为将在[后续步骤](#步骤-3编写互操作类)中用仓颉重写。

**支持的参数类型：** 任何[已映射](#objective-c-到仓颉映射)的 Objective-C 类型。

**支持的返回类型：** 任何已映射的 Objective-C 类型或 `void`。

**支持的继承：** 互操作类只能扩展镜像的 Objective-C 类（_不能_扩展其他互操作类），且只能实现镜像 Objective-C 协议的接口。

**限制：**

* 不支持变长参数（varargs）方法与构造函数。
* 互操作类及其各非私有成员函数均不得为泛型。
* 泛型 Objective-C 类型在镜像生成前会被擦除；各类型变元会被替换为相应上界。

**端到端示例：**

为简单起见，假设 iOS 应用中已有类 `M`，其具有单个无参 `void` 实例方法 `foo()`：

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

您希望在其子类 `A` 中用仓颉实现重写方法 `foo()`。

互操作类设计如下：

```objectivec
#import "M.h"
@interface A : M
- (void)foo;
@end
```

#### 步骤 2：生成镜像类型声明

现在需要为互操作类依赖的所有 Objective-C 类型获取[镜像类型](#镜像类型)声明：超类型、成员属性与局部变量的类型、方法参数/返回值的类型，以及（若涉及数组类型）元素类型。

在继续之前，请正常构建 iOS 应用且不做任何更改，以确保镜像生成器获得完整且一致的 Objective-C 头文件集合。

然后编写合适的[镜像生成器配置文件](#配置文件语法)并运行镜像生成器：

```bash
ObjCInteropGen <config-file>
```

其中 `<config-file>` 为配置文件路径名。

**端到端示例（续）：**

类 `A` 的唯一直接依赖是其超类 `M`，因此配置文件非常简单：

```toml
# A.toml
# 将 M 的镜像及其依赖放入 'objcworld' 包：
[[package]]
filters = { include = ["M", "NS.+"] }
package-name = "objcworld"

# 将镜像类型定义输出到当前目录：
[output-roots.default]
path = "."

# 指定输入头文件路径：
[sources.all]
paths = ["M.h"]

[sources-mixins.default]
sources = [".*"]
arguments-append = [
    # 若出现 "unknown type name" 错误，请取消注释以下行
    # "-DTARGET_OS_IPHONE=1",

    # 编辑以下路径以匹配系统中 Objective-C 头文件位置：
    "-F", "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/System/Library/Frameworks",
    "-isystem", "/Library/Developer/CommandLineTools/usr/lib/clang/17/include",
    "-isystem", "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include"
]
```

镜像生成器命令行：

```bash
ObjCInteropGen A.toml
```

上述命令将生成 `objcworld/M.cj`（含类 `M` 的镜像类型声明）以及若干 `objcworld/NS*.cj` 文件（含 `M` 所依赖的 Foundation 框架类与协议的镜像类型声明）。

##### 常见配置错误

**镜像生成器找不到标准头文件，例如 `stdarg.h` 或 `stdbool.h`。**

示例错误信息：

```text
..../CoreFoundation.h:19:10: error: 'stdarg.h' file not found
```

这通常表示 `[sources-mixins]` 表中 `arguments-append` 数组的路径不正确。请仔细核对它们是否与系统中头文件位置一致。

**镜像生成器报告 "Unknown type name 'NSUInteger'" 或类似错误。**

示例错误信息：

```text
.../NSObjCRuntime.h:626:74: error: unknown type name 'NSUInteger'
```

在某些系统上，需要向 Clang 传递额外参数 "`-DTARGET_OS_IPHONE=1`" 或 "`-DTARGET_OS_OSX=1`"。

将其加入 `[sources-mixins]` 表的 `arguments-append` 数组。上例中该配置存在但被注释：

```toml
# .  .  .
arguments-append = [
    # 若出现 "unknown type name" 错误，请取消注释以下行
    # "-DTARGET_OS_IPHONE=1",
# .  .  .
```

#### 步骤 3：编写互操作类

对[步骤 1](#步骤-1设计互操作层)互操作层设计中的每个 Objective-C 类骨架，按下列方式编写匹配的仓颉类：

* 使用合适的包名与类名（`cjc` 将生成的 Objective-C 包装类具有相同完全限定名）。
* 导入 `objc.lang.*`。
* 导入[步骤 2](#步骤-2生成镜像类型声明)生成的镜像类型；不要导入所有生成依赖，仅导入实际需要的类型。
* 为互操作类添加 `@ObjCImpl` 注解。
* 使互操作类继承相应的 `open` 镜像类；若设计中无显式超类型，则继承 `NSObject`。
* 为 `public` 类成员与构造函数添加 `@ForeignName["`_`foreign-name`_`"]` 注解，其中 _`foreign-name`_ 为该成员或构造函数在 Objective-C 侧的名称，规则如下：

  1. _不要_为重写镜像超类型成员函数的成员函数添加注解。互操作类中此类成员函数若存在 `@ForeignName` 注解将触发编译错误。

     > 此类重写函数的 Objective-C 名称必须与被重写的 Objective-C 方法一致。后者通过镜像超类型声明中的 `@ForeignName` 注解从 Objective-C 自动传播到仓颉（详见[类与协议](#类与协议)）。`cjc` 编译器会使用这些注解。

  2. _要_为具有两个及以上参数的构造函数和非重写成员函数添加注解。此类成员函数或构造函数若缺少 `@ForeignName` 注解将触发编译错误。

     > 编译器无法将具有两个及以上参数的成员函数或构造函数的原始仓颉名称自动变形为有效的 Objective-C 名称。此类名称本质上由用冒号 `:` 分隔的若干片段组成。

  3. 重载的成员函数与构造函数_必须_通过 `@ForeignName` 指定不同的 Objective-C 名称，因为 Objective-C 不支持方法重载。多个重载实体中至多一个可保留原仓颉名称，且其参数至多一个。

  4. 对其余成员与构造函数添加 `@ForeignName` 注解是可选的。若无 `@ForeignName` 注解，则此类成员的原始仓颉名称用作对应实体的 Objective-C 名称；单参数方法名后附加冒号 `:`；与唯一 `public` 构造函数（零或一个参数）对应的 `init` 方法分别称为 `init:` 或 `init`。

  **注意：** 当前版本的 `cjc` 编译器_未_完全校验 _`foreign-name`_，尤其不检查冒号 `:` 数量是否与成员函数或构造函数参数个数匹配。

* 使用下列 Objective-C 到仓颉类型映射（`T'` 为等价值类型或相应镜像类型）：

    Objective-C            | 仓颉          | 备注
    ---------------------- | ------------  | ------
    `void`                 | `Unit`        |
    `BOOL`                 | `Bool`        |
    `signed char`          | `Int8`        |
    `short`                | `Int16`       |
    `int`                  | `Int32`       |
    `long`                 | `Int64`       |
    `long long`            | `Int64`       |
    `unsigned char`        | `UInt8`       |
    `unsigned short`       | `UInt16`      |
    `unsigned int`         | `UInt32`      |
    `unsigned long`        | `UInt64`      |
    `unsigned long long`   | `UInt64`      |
    `float`                | `Float32`     |
    `double`               | `Float64`     |
    `struct`               | `@C struct'`  | (\*)
    `enum` 且基本类型为 `T` | `T'`          |
    `id`                   | `ObjCId`      | (†)

    Objective-C  | 仓颉           | 若 `T` 为...                              | 备注
    ------------ | ------------   | ----------------------------------------- | ------
    `T*`         | `CPointer<T'>` | ... 基本类型或结构体类型                    |
    `T*`         | `CPointer<U'>` | ... 枚举类型且 `U` 为其基本类型             |
    `T*`         | `CFunc<T>`     | ... 纯 C 函数类型                           |
    `T*`         | `T'`           | ... 类类型                                  | (†)

    (\*) Objective-C 结构体不得包含非 `CType` 兼容类型的字段。详见[结构体](#结构体)。

    (†) 对可能接收/持有 Objective-C `nil` 值的镜像类型与互操作类，在参数、返回值与局部变量处使用 `?<T'>`（`Option<T'>`）。

    详见 [Objective-C 到仓颉映射](#objective-c-到仓颉映射)。

**支持的特性：**

互操作类的成员函数：

* 可覆盖/重新定义镜像超类的 `open` 实例/静态成员函数，实现镜像超接口的成员函数，或作为新引入的成员函数。

互操作类的构造函数与成员函数：

* 在仅使用常规仓颉类型（的值）时，函数体中可使用任意仓颉语言特性。
* 可使用常规仓颉语法：
    - 实例化互操作类与镜像 Objective-C 类；
    - 调用互操作类与镜像 Objective-C 类型的静态和实例成员函数（包括使用 `super` 调用 Objective-C 超构造函数与超类方法）；
    - 访问自身成员属性及其他互操作类与镜像 Objective-C 类型的非 `private` 成员属性。

**限制：**

* 互操作类可实现镜像 Objective-C 协议的接口，但不能实现常规仓颉接口。
* 互操作类不得声明为 `open` 或 `abstract`，且不得使用 `extend` 扩展。
* 互操作类的非 `private` 成员函数与构造函数：
    - 参数与返回类型只能使用上述 Objective-C 映射类型。（因此不支持变长参数，因其需要使用无 Objective-C 映射的仓颉 `Array<T>` 类型。）
    - 不得拥有命名参数。
    - 不得拥有类型形参，即不得为泛型。
* 非 `private` 成员属性的类型只能使用上述 Objective-C 映射类型。
* 泛型 Objective-C 类型会被擦除；镜像类型以上界代替相应类型形参。
* **重要提示：** 镜像类型与互操作类的实例（即 Objective-C 引用类型的值）不得逃逸到全局或静态仓颉变量，或任何在调用之间持久存在的数据结构中。

**端到端示例（续）：**

继续上例，互操作类 `A` 如下：

```cangjie
package cjworld           // 包名相同

import objc.lang.*        // 始终需要

@ObjCImpl
public class A <: M {

    public init() {
        super()
    }

    override public open func foo(): Unit {
        println("Hello from overridden A.foo()")
    }

}
```

#### 步骤 4：编译互操作类

命令行：

```bash
cjc --target=arm64-apple-ios-simulator \
    --sysroot=$(xcrun --show-sdk-path --sdk iphonesimulator) \
    --output-type=dylib \
    --int-overflow=wrapping \
    <source-files> \
    -o <target-file> \
    --link-options "-undefined dynamic_lookup"
```

其中

`<source-files>` 为互操作类与镜像类型声明的源文件。

`<target-file>` 为输出 `.dylib` 文件的期望名称，例如 `libcjworld.dylib`。

编译器还将生成 Objective-C 源文件（`.h` 与 `.m`），用于互操作类的 Objective-C 包装器，并放在 `./objc-gen/` 子目录中。

`.dylib` 文件须签名：

```bash
xcrun codesign --sign - <dylib-file>
```

**端到端示例（续）：**

编译互操作类：

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

编译器将产生三个文件：`./libcjworld.dylib`、`./objc-gen/A.h` 和 `./objc-gen/A.m`。

为生成的动态库签名：

```bash
xcrun codesign --sign - libcjworld.dylib
```

#### 步骤 5：整合所有内容

**重要提示：当前版本的镜像生成器_未_将原始头文件名传播到镜像类型声明。因此，上一步生成的包装类将导入不存在的头文件且无法编译。下面给出临时解决方法。**

例如，若互操作类的成员函数接受和/或返回 UIKit 中的 `UIDevice` 类型，生成的包装类源文件将包含

```objectivec
#import "UIDevice.h"
```

而不是

```objectivec
#import <UIKit/UIKit.h>
```

或

```objectivec
#import <UIKit/UIDevice.h>
```

**注意：** Foundation 框架是例外，因为 `cjc` 生成的所有 Objective-C 文件顶部始终包含：

```objectivec
#import <Foundation/Foundation.h>
#import <stddef.h>
```

作为临时解决方法，需手动创建此类镜像类型的 `.h` 文件，写入正确的 `#import` 声明，并在继续之前将它们加入 Xcode 项目。

该不便将在未来版本中消除。

现在执行下列操作：

* 在项目中创建子目录，并将 `$CANGJIE_HOME/runtime/lib/ios_simulator_aarch64_cjnative/` 目录下的所有动态库复制到该目录。
* 将上述所有动态库_以及_[上一步](#步骤-4编译互操作类)生成的 `.dylib` 文件作为依赖项加入 Xcode 项目（BuildPhases — 在 “Copy Files” 与 “Link Binary With Libraries” 列表中）。
* 将[上一步](#步骤-4编译互操作类)生成的 `.h` 与 `.m` 文件移到项目根目录。

然后重新构建项目。

**端到端示例（续）：**

在项目根目录创建新子目录，并将构成 iOS 版仓颉运行时的动态库复制进去：

```bash
cd ..
mkdir -p CJRuntimeDylibs
cp $CANGJIE_HOME/runtime/lib/ios_simulator_aarch64_cjnative/*.dylib CJRuntimeDylibs/
```

将上述动态库_以及_ `./cjworld/libcjworld.dylib` 作为依赖项加入 Xcode 项目（BuildPhases — 在 “Copy Files” 与 “Link Binary With Libraries” 列表中）。

将 `cjc` 生成的 `.h` 与 `.m` 文件移到项目根目录：

```shell
mv cjworld/objc-gen/*.h ./
mv cjworld/objc-gen/*.m ./
```

重新构建 Xcode 项目。

### 从仓颉调用 Objective-C

按[上一节](#初始互操作类创建工作流)设计、构建并集成互操作层后，可在互操作类的成员函数中添加使用 Objective-C 类型的代码。类型映射相同。

通过互操作类包装器的相应方法，在 Objective-C 中添加调用仓颉函数的代码，并重新构建 iOS 项目。

**端到端示例（续）：**

在 Objective-C 代码中插入 `A` 的实例化及该实例 `foo()` 方法的调用：

```objectivec
       .  .  .
#import "M.h"
#import "A.h"
       .  .  .
    M* a = [[A alloc] init];
    [a foo];
       .  .  .
```

重新构建 Xcode 项目并在 iOS 模拟器上运行应用。

### 后续增强

按[上述流程](#初始互操作类创建工作流)操作后，应已理解如何向互操作层添加更多类，和/或在互操作层的仓颉代码中启用更多 Objective-C 类。以下是简要摘要及相应小节链接：

**[步骤 1](#步骤-1设计互操作层)：** 在设计中添加更多互操作类，和/或按需为现有互操作类增加方法与/或属性。

**[步骤 2](#步骤-2生成镜像类型声明)：** 若将涉及尚未镜像的额外 Objective-C 引用类型，先构建应用_当前_版本以确保一致性，适当编辑镜像生成器配置文件，然后（重新）生成所有镜像类型声明。

**[步骤 3](#步骤-3编写互操作类)：** 实现新添加的互操作类（如有），和/或修改现有互操作类代码，按需使用镜像 Objective-C 类型。

**[步骤 4](#步骤-4编译互操作类)：** 一起编译所有互操作类。

**[步骤 5](#步骤-5整合所有内容)：** 将 `cjc` 在上一步生成的 `.h`、`.m` 与 `.dylib` 文件复制到项目中相应位置并重新构建。

现在可以[在 Objective-C 中](#从仓颉调用-objective-c)使用新添加的互操作类及/或方法。

### 互操作类的特性与限制

1. 互操作类_必须_是镜像类的直接子类。

2. 互操作类_可以_实现一个或多个镜像接口，但_不能_实现常规仓颉接口。反之，常规仓颉类型_不能_实现或继承镜像 Objective-C 协议的接口。

3. 互操作类不得声明为 `open` 或 `abstract`，不得使用 `extend` 扩展，且不得为泛型。

4. 互操作类可引入任意 Cangjie 类型的新实例字段（因其不暴露给 Objective-C），并重写其镜像超类的成员函数。

5. 互操作类的构造函数可使用 `super()` 调用超类构造函数，但对实例成员函数调用的限制与常规仓颉构造函数相同，且须初始化所有新引入的成员变量。

6. 互操作类的实例成员函数可调用从镜像超类继承的实例成员函数，和/或使用 `super.` 调用互操作类所重写的超类成员函数。

7. 所有镜像类型与互操作类的构造函数与成员函数签名只能使用 [Objective-C 兼容类型](#objective-c-兼容类型)。类型映射表见[步骤 3](#步骤-3编写互操作类)及[Objective-C 到仓颉映射](#objective-c-到仓颉映射)章节。

## Objective-C 到仓颉映射

当前版本的镜像生成器会执行以下 Objective-C →仓颉转换。

### 一般注意事项

Objective-C 镜像生成器依赖 Clang 来解析 Objective-C 源代码，通过`-fobjc-arc`选项。

带 `unavailable` 属性的声明会被忽略。

全局、文件级函数和变量声明也会被忽略。

输出仓颉源代码中的声明顺序与输入 Objective-C 源代码中各自定义的顺序相同，嵌套类型定义除外。

### 名称

原 Objective-C 标识符一般情况下都会被原样保留，但有以下例外：

* 与仓颉关键字冲突的 Objective-C 标识符（如 `catch`、`false` 或 `UInt32`）会用反引号 ``` `` ``` 括起。
* Objective-C 类与协议之间的名称冲突通过向协议名称添加 `Protocol` 后缀解决。
* 实例方法与静态方法之间的名称冲突若可解决，会向发生冲突的最高（最靠近根的）类/协议添加 `Instance` 或 `Static` 后缀。若冲突的实例/静态方法在同一类/协议中首次引入，则重命名静态方法。例如：

    ```objectivec
    @interface A
    +(void)foo;
    @end

    @interface B : A
    -(void)foo;
    +(void)bar;
    -(void)bar;
    @end
    ```

    将被镜像到

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

* 具有相同参数数量与类型的 `init` 方法之间的冲突会被解决，但存在限制。详见[类](#类)。

### 类型别名

C typedef 声明被镜像为 public 仓颉类型别名。

### 基本类型

Objective-C 基本类型映射到相应仓颉值类型。具有平台特定大小的 C 类型根据其在_主机_平台（即运行镜像生成器的平台）上的实际大小映射到仓颉。例如在 macOS 上可能为：

| Objective-C          | 仓颉        |
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

### 字符串

仓颉 `String` 类型与 Objective-C `NSString` 类型不二进制兼容，字符数据编码也不同（分别为 UTF-8 与 UTF-16）。

为便于字符串转换，仓颉编译器隐式扩展 Foundation 框架类 `NSObject` 与 `NSString` 的镜像，如下：

* `NSObject` 类的镜像具有隐式定义的实例成员函数 `toString()`：

  ```cangjie
      public open func toString(): String
  ```

  该函数调用接收者的 `description` 方法，将结果转换为仓颉 `String` 并返回。

* `NSString` 类的镜像具有隐式定义的、接受仓颉 `String` 参数的构造函数：

  ```cangjie
      public init(s: String)
  ```

  它使用参数的转码字符数据初始化正在构造的 `NSString` 实例。

**注意：** 这些镜像类本身如何命名并不重要。其 `@ObjCMirror` 注解的值必须分别为 `"NSObject"` 与 `"NSString"`，编译器才会插入上述隐式声明：

```cangjie
  @ObjCMirror["NSObject"]
  public class ObjC_Object {    // 隐式添加 toString()
      //   .  .  .
  }
  ```

```cangjie
  @ObjCMirror["NSObjectWrapper"]
  public class NSObject {       // 未隐式添加 toString()
      //   .  .  .
  }
  ```

### 结构体

若 C 结构体 `CType` 兼容（即仅包含 `CType` 兼容类型的字段），则被镜像为标记 `@C` 的 public 仓颉 struct。其他场景（例如原 Objective-C 结构体包含对象指针）目前不支持。

嵌套结构被镜像为顶层仓颉 struct。

不完整结构声明被镜像为空 struct（无任何成员）。

Objective-C 结构体字段被镜像为相应仓颉 struct 的 public 成员变量。`static` 修饰符会保留。

仓颉不支持位域，位宽会被忽略并发出警告。

仓颉与 Objective-C 不同，要求 struct（包括 `@C` struct）的所有成员变量均须初始化，因此镜像 struct 为所有字段包含显式零初始化器。例如：

```c
struct A {
    int x;
    double y;
    BOOL z;
    struct A *w;
};
```

被镜像到

```cangjie
@C
public struct A {
    public var x: Int32 = 0
    public var y: Float64 = 0.0
    public var z: Bool = false
    public var w: CPointer<A> = CPointer<A>()
}
```

### 枚举

命名的 C 枚举声明被镜像到抽象的密封仓颉类（即命名空间）中。枚举器被镜像到使用其值初始化的公共静态常量中。它们的类型对应于为枚举显式指定的基础类型（如果有），否则为`Int32`.

### 联合体

仓颉语言不支持 C 联合类型。联合被镜像到具有顺序字段的结构体，并发出警告。

### `id`

类型 `id` 被镜像为内置镜像接口 `ObjCId`。

### 类与协议

Objective-C 类与协议分别被镜像为仓颉 class 与 interface。所有此类镜像类与 interface 均隐式实现/继承内置 `ObjCId` 镜像接口（见[内置类型](#内置类型)）。

**方法**（`init` 方法除外，见下文）被镜像为 `public open` 成员函数，参数与返回类型替换为相应镜像类型。`void` 方法的镜像具有 `Unit` 返回类型。`instancetype` 被镜像为当前声明的类型名。类方法（带 "`+`" 前缀）的镜像添加 `static`。

`init` 方法是特例，被镜像为构造函数，见[类](#类)。

所有方法的镜像均省略函数体，因此在常规仓颉代码中均呈现为抽象成员函数。

在具有可变参数数量的方法中，`, ...` 会被忽略。

完整的 Objective-C 方法名（选择器）含 `:`，不是有效仓颉标识符。此类名称按下列规则变形：

* 每个紧跟 `:` 的字母（如有）大写。
* 删除所有 `:`。

原选择器保留在 `@ForeignName` 注解中。

**示例：**

```objectivec
@interface A
- (void)foo;
- (void)foo:(int)i;
- (void)foo:(int)i bar:(int) j;
- (void)foo:(int)i bar:(int) j baz:(int) k;
@end
```

被镜像到

```cangjie
@ObjCMirror
public open class A {
    public open func foo(): Unit

    @ForeignName["foo:"]
    public open func foo(i: Int32): Unit

    @ForeignName["foo:bar:"]
    public open func fooBar(i: Int32, j: Int32): Unit

    @ForeignName["foo:bar:baz:"]
    public open func fooBarBaz(i: Int32, j: Int32, k: Int32): Unit
}
```

**属性通常镜像到**`public`各自的镜像类型的成员属性，但有一个例外：重写超类属性的属性不被镜像。

身体(`{ }`包含 getter 和 setter 的块在属性的镜像中被省略。

仓颉属性的 getter/setter 函数不能任意命名。注解`@ForeignGetterName`和`@ForeignSetterName`保留原始 getter 和 setter 的自定义名称（如果有）：

```objectivec
@interface FormElement : UIComponent
- (void)setEditable:(BOOL)flag;
- (BOOL)isEditable;
@property(getter=isEditable, setter=setEditable:) BOOL editable;
//   .  .  .
@end
```

```cangjie
public interface FormElement <: UIComponent {
    @ForeignGetterName["isEditable"]
    @ForeignSetterName["setEditable:"]
    public mut prop editable: Bool
//   .  .  .
}

```

#### 类

Objective-C`@interface`类声明被镜像到`public open`仓颉类注`@ObjCMirror`.该注解的值是一个字符串，如果与镜像类名不同，则保留 Objective-C 类的原始名称。

Objective-C`@interface`类别和扩展声明与各自的仓颉类声明合并。

Objective-C`@implementation`声明将被忽略。

正向类声明(`@class`指令)被镜像到空类（没有任何成员）中。

**方法被确定为`init`方法**按照[Objective-C ARC 的 Clang 文档中的方法家族部分](https://clang.llvm.org/docs/AutomaticReferenceCounting.html#method-families) 镜像到仓颉构造函数，有三个限制：

* 如果两个或两个以上`init`一个类的方法仅在名称上有所不同，即具有相同数量和类型的参数，它们不能镜像到重载的构造函数中。相反，它们被镜像到`static`使用注解的成员函数`@ObjCInit`，它返回被镜像的类的实例，本质上是对象工厂：

    ```objectivec
    @interface Point2D : NSObject {
        double x;
        double y;
    }
    - (id)init;
    - (id)initWithX:(double)x;
    - (id)initWithY:(double)y;
    - (id)initWithX:(double)x andY:(double)y;
    @end
    ```

    ```cangjie
  @ObjCMirror
  public open class Point2D {
      public init()

      @ObjCInit
      @ForeignName["initWithX:"]
      public static func initWithX(x: Float64): Point2D

      @ObjCInit
      @ForeignName["initWithY:"]
      public static func initWithY(y: Float64): Point2D

      @ForeignName["initWithX:andY:"]
      public init(x: Float64, y: Float64)
  }
  ```

    这些工厂函数的名称源自于各自的 Objective-C 的原始名称`init`方法，而后者则保留在`@ForeignName`注解，其方式与对任何其他镜像方法执行的方式完全相同。请参阅[类和协议](#类与协议) 的详细信息。

* 在 Objective-C 中，`init`方法和其他方法一样是继承的，而仓颉中的构造函数不是继承的。镜像的构造函数`init`因此，在镜像类或互操作类实例化时，超类的方法不可用。相反，工厂函数镜像了某些`init`继承了上一项中的方法，但不能用作超构造函数，因为它们返回的是完全初始化的超类实例。
* 与总是初始化接收者对象的构造函数不同，Objective-C`init`方法可以返回一个替代对象，并且具有显式的返回类型。以前那种类型`id`，所以严格来说`init`方法甚至可以返回一个完全不同的类的实例。在[现代 Objective-C 代码](https://developer.apple.com/library/archive/releasenotes/ObjectiveC/ModernizationObjC/AdoptingModernObjective-C/AdoptingModernObjective-C.html) ，但是，返回类型`init`方法通常是`instancetype`，一个特殊的关键字，意思是"指向接收者类（的子类）实例的指针"。(Xcode 编译器实际上提升了`id`到`instancetype`对于已知的方法，例如`init`和`alloc`，但不是对象工厂。)使用`instancetype`确保返回的对象至少属于正确的类，但不排除返回`nil`值。实际上，返回`nil`从一个`init`方法是向调用者发出信号通知的推荐方式，表明由于不需要引发异常的原因无法初始化对象。

    目前的执行预期`init`方法返回相应类的实例，并且不验证返回值。**警告：如果`init`从仓颉返回调用的方法`nil`或指向不是接收者类（的子类）的类实例的指针，则行为未定义。**

**实例变量被镜像到各自镜像类型的实例成员变量中。Objective-C 中没有类变量。**

#### 协议

Objective-C`@protocol`指令被镜像到标记为的仓颉界面中`@ObjCMirror public`.

正向协议声明被镜像到空接口（没有任何成员）。

**Objective-C 协议的方法被镜像到相应的仓颉接口的成员函数中。类方法的镜像(带有"**`+`"前缀)被修改为`static`.

Objective-C 协议可能包含可选的实例方法，这些方法在仓颉中没有直接的等价物。镜像这些方法的成员函数用注释`@ObjCOptional`.桥接代码实现跨语言调用`@ObjCOptional`方法首先检查接收者是否实现了它，抛出`NotImplementedException`如果它没有。

```objectivec
@protocol MyDelegate <NSObject>

@required
- (void)requiredMethod;

@optional
- (void)optionalMethod;
@end
```

```cangjie
@ObjCMirror
public interface MyDelegate {
    func requiredMethod(): Unit

    @ObjCOptional
    func optionalMethod(): Unit
}
//   .  .  .
    try {
        delegate.optionalMethod()
    } catch (nie: NotImplementedException) { } // OK，无大碍
```

### 指针

修改器`const`，`volatile`，和`restrict`都被忽略。

指向 C 基本类型及其类型别名的指针被镜像为 `CPointer<`_`T`_`>`，其中 _`T`_ 为匹配的仓颉类型。

指向 C 枚举的指针镜像到`CPointer`到其基础类型，实际的枚举名称在注释中指定。

#### 指向结构体的指针

指向 C 结构体的指针`T`被镜像到`CPointer<T'>`，其中`T'`是的镜像类型`T`，如果结构体是`CType` 兼容，否则会镜像到内置类型`ObjCPointer<T'>`.

#### 指向函数的指针

指向 C 函数的指针被镜像到`CFunc`(如果函数参数类型和返回值都是`CType` 兼容)或`ObjCFunc<F>`否则，后者是内置的结构体类型，其公共接口由单个属性组成：

```cangjie
public struct ObjCFunc<F> {
    public prop call: F
}
```

编译器会对该类型实施一些限制：

* 参数的类型和函数类型的返回值用作类型参数_`F`_的`ObjCFunc<`_`F`_`>`必须是[Objective-C 兼容](#objective-c-兼容类型) ，但类型_`F`_本身不 Objective-C 兼容。
* 属性 `call`只能在函数调用表达式中使用。
* 没有办法创建一个实例`ObjCFunc<F>`在仓颉代码中，所有这些实例都源自 Objective-C 代码。
* 目前还没有直接的方法来检查某个`ObjCFunc<F>`从 Objective-C 传递过来的是`null`.

#### 指向块的指针

指向 Objective-C 块的指针被镜像到内置的结构体类型`ObjCBlock<`_F_`>`，其中_`F`_是各自的仓颉功能类型。的公共接口`ObjCBlock<F>`由单个构造函数和单个属性组成：

```cangjie
public struct ObjCBlock<F> {
    public init(f: F)
    public prop call: F
}
```

编译器会对该类型实施一些限制：

* 参数的类型和函数类型的返回值用作类型参数_`F`_的`ObjCBlock<`_`F`_`>`必须是[Objective-C 兼容](#objective-c-兼容类型) .注意：这不会使类型_`F`_它本身是 Objective-C 兼容的。
* 属性 `call`只能在函数调用表达式中使用。
* 目前还没有直接的方法来检查某个`ObjCBlock<F>`从 Objective-C 传递过来的是`null`.

不像`ObjCFunc<F>`的实例`ObjCBlock<F>`可以从 lambda 表达式在仓颉代码中创建：

```cangjie
let halve: ObjCBlock<(Double) -> Double> =
    ObjCBlock { it => it / 2.0 }
```

块可从仓颉调用：

```cangjie
let x = halve.call(2.0)    // x == 1.0d
```

并作为参数传递给镜像的 Objective-C 方法和函数。

#### 指向类实例的指针

Objective-C 类实例的指针镜像如下

* 指向类实例的指针(`SomeClass*`)被镜像到各自的镜像类类型。
* Objective-C 类型的镜像`id`使用单一协议(例如，`id<NSCopying>`)，是该协议的镜像接口。
* `id`有几个协议，例如。`id<NSCopying, NSSecureCoding>`，被镜像成一个纯粹的`ObjCId`(所有的接口`@ObjCMirror`类和接口分别实现和继承，实际的协议列表在注释中指定。
* 如果泛型类型参数在泛型模板中使用指定的缩窄协议，则它将镜像到对该协议的引用，并在注释中指定类型参数的名称。

当用作参数、返回值或成员变量的类型时，这样的镜像类型会被包装在`Option<T>`，除非所述实体被注释为不可为空。这样就能安全通过`nil`Objective-C 和仓颉之间的值，参见[`nil`处理方式](#nil-处理) 的详细信息。

### 泛型

参数化的 Objective-C 类被镜像到常规的、非泛型的类声明中。原始的轻量级泛型语法，如`<T>`"或"`<Foo>`"在注释中保留；类型参数用法替换为`ObjCId`.

**示例：**

```objectivec
@interface G<T> : NSObject
- (void)f:(T)t;
@end
```

被镜像到

```cangjie
@ObjCMirror
public open class G/*<T>*/ <: NSObject {
    @ForeignName["f:"] public open func f(t: ?ObjCId /*T*/): Unit
}
```

但是，在当前版本中，类型约束丢失，即。

```objectivec
@interface G<T: SomeType*> : NSObject
- (void)f:(T)t;
@end
```

现在与上面的第一个样本完全镜像。

### 顶层函数

顶级 Objective-C 函数镜像到全局`public`用注释的函数声明`@ObjCMirror`的镜像类型，分别替换为参数类型和返回值类型。的镜像`void`函数具有`Unit`返回类型。省略了函数体。

为了避免疑问，即使函数的所有参数类型和返回类型满足`CType`一个原因是一个常规的`@C`外部函数声明不能`public`在仓颉。

在参数个数可变的函数中，`, ...`被忽略。

### 内置类型

镜像生成器假定在 interop 库中实现了以下用户可用的仓颉类型。但是，在当前版本中，其中一些（标有"？"）尚未实现，它们的名称可能会更改。

| Objective-C                       | 仓颉(\*)              | 描述                                                            |
| --------------------------------- | ------------------- | ------------------------------------------------------------- |
| `id`                              | `ObjCId`            | 所有隐式实现的接口`@ObjCMirror`类和接口。绑定到 Objective-C`id`.                |
| `SEL`                             | `SEL`？              | Objective-C 绑定的类`SEL`.                                         |
| `Class`                           | `Class`？            | Objective-C 绑定的类`Class`.                                       |
| [指针类型](#指针)                 | `ObjCPointer<T>`    | Objective-C 指针绑定的结构体有两种：一种是 arity 多于一个，另一种是`T`不是一个`CType` 兼容结构。 |
| [非 C 函数类型](#指向函数的指针)  | `ObjCFunc<F>`       | 类实现`CFunc`对于函数，不是`CType` 兼容。`F`是一个仓颉函数类型。                    |
| [块类型](#指向块的指针)        | `ObjCBlock<F>`      | 实现 Objective-C 块的结构。`F`是一个仓颉函数类型。                               |
|                                   | `__builtin_va_list` | 的帮助程序类型别名`CPointer<Unit>`在当前生成器实现中，技术上需要。可能，并且应该在未来被删除。       |

（\*）仓颉类的名称是暂时的。

### 尚未实现的功能

仓颉 SDK 中的 Objective-C 互操作性支持仍在开发中。某些功能尚未实现，其他功能可能会在第一个生产版本中发生变化，由于两种语言之间的主要差异，有些功能无法（完全）实现。

* 改变数据的默认大小、打包、填充和/或对齐的 C 语言功能是非常特定于 ABI 的。仓颉语言不支持这样的低级特性，尤其是位域。因此，镜像生成器会忽略位域宽度说明符并发出警告。
* 仓颉语言不提供对 C 联合类型的支持，因此它们被镜像为结构体，并发出警告。
* 字段类型非 `CType` 兼容的结构体不受支持。
* 匿名 C 枚举声明将被忽略。命名的被镜像成抽象的密封仓颉类，参见[枚举](#枚举) 的详细信息。
* 在参数数量可变的方法中，`...`被忽略。
* 与内存管理相关的注解，如`NS_RETURNS_RETAINED`，将被忽略。
* 与 `@optional` 相关的注解会被忽略。
* 如果可能，属性将镜像为属性，否则它们的 getter 和 setter 方法将镜像为常规实例方法。请参见[类和协议](#类与协议) 的详细信息。
* 修改器`const`和`volatile`都被忽略。
* 类型`SEL`和`Class`不支持。
* 与镜像 Objective-C 类的实例的构建有关的一些细微差别：

    * 该`init`Objective-C 类的方法通常被镜像到构造函数中，除非其中两个或更多的方法具有完全相同的参数数量和类型。`init`方法被镜像到`static`工厂成员函数用注解`@ObjCInit`.但是，这样的函数不能用作超级构造函数。
    * 仓颉中的构造函数不是继承的，不像`init`方法（但工厂函数是）。
    * 一个 `init`方法可以返回`nil`，仓颉不希望在当前版本中出现，导致应用异常终止。未来的版本将抛出`NoneValueException`在这种情况下。

    详见[类](#类)。
* 参数化的 Objective-C 类被镜像到常规的、非泛型的仓颉类声明中。[泛型](#泛型) 的详细信息。
* 重写超类属性的属性不会被镜像。
* Objective-C 错误处理只能使用`ObjCPointer<Option<`_`NSError'`_`>>`类型，其中_`NSError'`_是镜像的名称`NSError`类。

### `nil` 处理

仓颉没有空引用概念，因而没有 Objective-C `nil` 的等价物。若指向 Objective-C 类与协议的指针被镜像为仓颉 class 与 interface，从 Objective-C 传入的任何此类值都可能导致段错误；仓颉代码访问镜像字段中的 `nil` 时亦然。反之，也无法从仓颉向 Objective-C 传递 `nil`。

因此通常用 `Option<T>` 枚举表示这些 Objective-C 类型的值：`None` 表示 `nil`，`Some(r)` 表示非空引用 `r`。若 `T` 为镜像类型或互操作类，`cjc` 编译器将 `Option<T>` 识别为 Objective-C 兼容类型并相应映射其值。

例如，下面的 Objective-C`@interface`指令：

```objectivec
@interface MyContainer: NSObject
//   .  .  .
- (void)addItem:(MyItem *)item withUuid:(NSString *)uuid;
- (MyItem *)itemWithUuid:(NSString *)uuid;
- (NSString *)uuidForItem:(MyItem *)item;
@property (copy) NSArray<MyItem *> *allItems;
@end
```

将镜像到(`@ForeignName`为简洁起见，省略了注释)：

```cangjie
@ObjCMirror
public open class MyContainer <: NSObject {
//       .  .  .
    public open func addItemWithUuid(item: ?MyItem, uuid: ?NSString): Unit
    public open func itemWithUuid(uuid: ?NSString): ?MyItem
    public open func uuidForItem:(item: ?MyItem): ?NSString
    public open mut prop allItems ?NSArray/*<MyItem>*/
}
```

`Option<T>` 包装可避免因 Objective-C 侧传入 `nil` 导致仓颉代码崩溃，但会以性能与内存占用为代价。另一缺点是[方差损失](#方差损失)。不过，[对可空性注解的支持](#可空性注释) 可显著减轻引用包装的影响，至少在仓颉代码中使用 iOS API 时如此。

**注意：** 此问题不适用于镜像为常规 `CPointer<T>` 的低层 C 类型，因为后者提供显式空检查成员函数。

#### 方差损失

[`Option<T>` 包装](#nil-处理) 给 Objective-C 镜像类型与互操作类带来的限制是：此类包装类型在其他方面均遵循仓颉语义。特别是，`Option<T>` 对其类型形参 `T` _不变_：若 `U` 是 `T` 的子类型但 `U` 与 `T` 不完全相同，则 `Option<U>` 不是 `Option<T>` 的子类型。对镜像类型而言，任何依赖返回类型协变的重写 Objective-C 方法无法按此方式镜像；此类方法镜像的返回类型须与其所重写方法一致。

**示例：**

假设 Objective-C 类 `Foo` 是类 `Bar` 的直接超类：

```objectivec
@interface Foo : NSObject
@end

@interface Bar : Foo
@end
```

类 `C` 声明返回 `Foo` 实例的方法 `get`：

```objectivec
@interface C : NSObject
- (Foo*) get;
@end
```

`C` 的子类可用更精确的返回类型 `Bar` 重写 `get`：

```objectivec
@interface D : C
- (Bar*) get;
@end
```

没有`Option<T>`包装，所有这些类都可以镜像到：

```cangjie
@ObjCMirror
public open class Foo <: NSObject {}

@ObjCMirror
public open class Bar <: Foo {}

@ObjCMirror
public open class C <: NSObject {
    open func get(): Foo
}

@ObjCMirror
public open class D <: C {
    open func get(): Bar       // 返回类型协变
}
```

但是如果`get()`可以返回`nil`，应用程序崩溃是不可避免的。

`Option<T>`包装使它是安全的，但是所有重写方法的返回类型必须降低为原始方法的返回类型：

```cangjie
@ObjCMirror
public open class Foo <: NSObject {}

@ObjCMirror
public open class Bar <: Foo {}

@ObjCMirror
public open class C <: NSObject {
    open func get(): Option<Foo>
}

@ObjCMirror
public open class D <: C {
    // open func get(): Option<Bar>  // 错误，`Option<T>` 对 T 不是协变的
    open func get(): Option<Foo>     // OK，但返回类型被降低
}
```

[可空性注释](#可空性注释) 部分缓解问题。

#### 可空性注释

在 XCode 6.3 发布的那天，为了更好地与新的 iOS/OS X 开发语言 Swift 集成，在 Objective-C 中引入了 nullability 关键字。所有 iOS API 的定义都通过可空性注释增强，以减少 Swift 代码中使用这些 API 的可选项的使用。

> **Objective-C 可空性注释**
>
> 的关键字`nullable`和`nonnull`可以用于 Objective-C 属性、方法结果类型和方法参数类型。它们分别意味着给定实体可以或不可以持有或接受`nil`值。（非常罕见）`null_unspecified`注解表示不知道它们的值是否为`nil`.
>
> 此外，任何指针类型都可以用`__nullable`，`__nonnull`或`__null_unspecified`具有相同的语义。
>
> 最后，属性也可以使用注解`null_resettable`，意味着它的 getter 永远不会返回`nil`，但通过`nil`的 setter 会将属性重置为某个默认值。
>
> 具体操作请参见[在 Objective-C API 中指定可空性](https://developer.apple.com/documentation/swift/designating-nullability-in-objective-c-apis) 在 Apple 开发者网站上。

因此，注解为不可为 null 的 Objective-C 引用类型的所有使用都不受`Option<T>`包装。换句话说，Objective-C 镜像生成器只为属性、方法结果类型和方法参数类型发出包装类型，而这些类型都没有被注解`nonnull`或`_Nonnull`在原始的 Objective-C 代码中。

假设从[本节介绍](#nil-处理) 增强了可空性注释，如下所示：

```objectivec
@interface MyContainer: NSObject
//   .  .  .
- (void)addItem:(nonnull MyItem *)item withUuid:(nonnull NSString *)uuid;
- (nullable MyItem *)itemWithUuid:(nonnull NSString *)uuid;
- (nullable NSString *)uuidForItem:(nonnull MyItem *)item;
@property (copy, nonnull) NSArray<MyItem *> *allItems;
@end
```

然后镜像生成器会绕过`Option<T>`的包装`nonnull`实体(`@ForeignName`为简洁起见，省略了注释)：

```cangjie
@ObjCMirror
public open class MyContainer <: NSObject {
//       .  .  .
    public open func addItemWithUuid(item: MyItem, uuid: NSString): Unit
    public open func itemWithUuid(uuid: NSString): ?MyItem
    public open func uuidForItem:(item: MyItem): ?NSString
    public open mut prop allItems: NSArray/*<MyItem*>*/
}
```

**注意：** 目前无法镜像**`null_resettable`属性转换为仓颉属性，同时传播该注释的语义，因此后者被完全视为`nullable`.

**如果你想要从仓颉访问的 Objective-C 代码没有利用可空性注释，你可能需要至少添加`nonnull`在开始使用此处介绍的仓颉 SDK 互操作功能之前，请根据需要进行注释。**这可能会大大减少使用`Option<T>`封装在各自的镜像类型中，使互操作类的代码更干净，更易读。

### 外部类型转换与测试

仓颉算子`is`和`as`都支持[外部类型](#外部类型) ，以及类型模式_`v`_`:`_`T`_在 match、if-let 和 while-let 表达式中（有关适用的限制，请参阅下一段）。但是请注意，这些类型的类型测试和转换的语义与 Objective-C 的语义匹配，并且这些操作在一般情况下是在 Objective-C Runtime 函数的帮助下进行的。

从当前版本开始，if-let 和 while-let 的支持是有限的：`let`表达式必须构成整个条件表达式，即不能使用逻辑二元运算符与另一个条件表达式组合`&&`或`||`.

**重要提示：镜像类型和互操作类的可空值，使用 _`Option<T>`_ 包装如中所述[`nil`处理方式](#nil-处理) 在类型测试之前，需要进行 null-test 和 unwrapping。原因是仓颉泛型对于它们的类型参数是不变的：_`e`_`is ?`_`T`_求值为`true`只有当类型为_`e`_是`Option<`_`T`_`>`具体来说，不是一些`Option<`_`U`_`>`其中_`U`_`<:`_`T`_.此外，值是否为 _`e`_ 是`Some(`_`v`_`)`或`None`；_`v`_ 根本没有经过类型测试。

## Objective-C 镜像生成器参考

### 前提条件

使用镜像生成器前，请运行仓颉 SDK 中的 `envsetup.sh` 脚本。

你需要知道框架和库的头文件的路径名，其中定义了你要镜像的类的所有依赖项。这包括 iOS 标准库头文件的位置，以及 Objective-C 编译器在构建项目时查找头文件的所有目录。

### 命令行语法

`ObjCInteropGen [-v] _`config-file`_`

`-v`

产生详细输出。

_`config-file`_

配置文件的路径名。

### 配置文件语法

Objective-C 镜像生成器配置文件是一个纯文本文件，在[TOML](https://toml.io) 语法。它指定：

* 输出目录
* 源 Objective-C 头文件的名称(`.h`\-文件)
* 输出仓颉包的名称以及镜像类型在它们之间的分布
* 要以特殊方式处理的类型的映射

被解释为正则表达式的字符串值必须跟在[ECMAScript 正则表达式语法](https://262.ecma-international.org/#sec-regular-expressions) .

#### 输出目录根

中的每个条目`[output-roots]`table of table 定义了本地文件系统中目录的路径名的符号名。镜像生成器将使用该路径名作为一个或多个特定于软件包的输出目录的公共根，使用`output-root`各自的财产[`[[package]]`数组](#包) 元素。

**示例：**

```toml
[output-roots.lib]
path = "./lib/src"

[output-roots.app]
path = "./main/src"

[[package]]
package-name = "com.vendor1.lib1"
output-root = "lib"  # Output to "./lib/src/com/vendor1/lib1"
filters = ...

[[package]]
package-name = "com.vendor2.lib2"
output-root = "lib"  # Output to "./lib/src/com/vendor2/lib2"
filters = ...

[[package]]
package-name = "com.mycompany.app"
output-root = "app"  # Output to "./main/src/com/mycompany/app"
filters = ...
```

#### 源文件

中的每个条目`[sources]`table of table 指定了一组单独的头文件，镜像生成器必须将这些头文件作为输入。

**属性：**

`paths`（必填）

一个字符串数组，其中包含镜像生成器必须读取的各个头文件的路径名。

`arguments`（可选）

包含 Clang 选项的字符串数组，镜像生成器在处理中列出的源文件时将传递这些选项`paths`.

**示例：**

```toml
[sources.all]
paths = ["original-objc/M.h"]
```

#### 附加 Clang 参数

中的每个条目`[sources-mixins]`表指定一个正则表达式，与[`[sources]`表](#源文件) 和其他参数，这些参数在处理来自其各自条目的头文件时必须传递给 Clang。

**属性：**

`sources`（必填）

包含正则表达式的字符串。

`arguments-prepend`
`arguments-append`（可选）

字符串数组，镜像生成器在处理以下文件时将作为选项传递给 Clang`[sources]`表项中的键与`sources`属性。

中列出的选项`arguments-prepend`和`arguments-append`将分别在选项的前面和后面传递`arguments`每个匹配的属性`[sources]`条目（如果有）。

**示例：**

```toml
[sources.UIWidgets]
paths = ["objc/UIWidgets.h"]
arguments = [ "-I", "/usr/local/include/share/Widgets" ]

[sources.UIPanels]
paths = ["objc/UIPanels.h"]
arguments = [ "-I", "/usr/local/include/share/Panels" ]

[sources-mixins.UI]
# Add these Clang arguments for both UIWidgets and UIPanels
sources = ["UI.+"]
arguments-append = [
    "-I", "/usr/local/include/Frameworks/AcmeUI"
]
```

#### 包

中的每个条目`[[package]]`array 指定了一个目标的包名，一组名称过滤器，定义了哪些 Objective-C 实体将镜像到该包，以及（可选）该包特定的输出目录。

**属性：**

`package-name`（必填）

包含目标仓颉包名的字符串。

`output-path`（可选）

一个字符串，其中包含镜像生成器应将给定包的输出文件放入的目录的确切路径名。如果该路径名中的任何目录都不存在，镜像生成器将尝试创建它们。

`output-root`（可选）

一个字符串，其中包含[`output-roots`表](#输出目录根) 目标仓颉包的名称将附加到相应的`output-roots`表项，点`.`替换为文件分隔符`/`，并且生成的路径名将被使用，就像它是`output-path`.

如果`output-root`没有设置，如果中只有一个元素`[output-roots]`，则使用该条目的路径名。否则，将显示错误。

**示例：**

```toml
[output-roots.main]
path="./cj-mirrors"

[[package]]
package-name = "objc.foundation"
output-root = "main"
```

输出文件将放在`./cj-mirrors/objc/foundation`.

`filters`（必填）

定义一组名称过滤器的表，这些过滤器仅从源文件中选择那些必须镜像到给定仓颉包的 Objective-C 实体声明。请参阅[名称筛选器](#名称过滤器) 的详细信息。

**示例：**

```toml
# The Foundation framework
[[package]]
package-name = "objc.foundation"
filters = { include = "NS.+" }
```

##### 名称过滤器

每个名称筛选器又是一个 TOML 表，其中包含：

* 正好是其中一个属性`include`，`exclude`，`union`，`intersect`和`not`，和
* 可选地，`filter`财产和/或`filter-not`属性。

属性的说明如下。

`include`

值可以是正则表达式或其数组。如果值是单个正规则，则只有与它匹配的名称才会通过过滤器。如果值是一个数组，则名称只需要匹配该数组中的任何单个 regex 即可传递。

**举例：**

```toml
# Only include entities that names of which start with "NS":
filters = { include = "NS.+" }

# Only include entities with names that either start with "Foo"
# or end with "Bar":
filters = { include = ["Foo.*", ".*Bar"] }
```

`exclude`

的反义词`include`（见上文）。一个名字，会通过一个`include`具有给定值的过滤器不会通过`exclude`具有相同值的过滤器，反之亦然。

**示例：**

```toml
# Include everything but entities the names of which start with "INTERNAL_":
filters = { exclude = "INTERNAL_.+" }
```

`union`

组合两个或多个过滤器的操作符。它的值必须是过滤器的数组。通过这些过滤器中的任何一个的名称都会通过整个`union` 过滤器。

**示例：**

```toml
# An equivalent of the second `include` example above:
filters = { union = [ { include = "Foo.*" }, { include = ".*Bar" } ] }
```

`intersect`

组合两个或多个过滤器的操作符。该值必须是过滤器的数组。一个名字必须通过所有这些才能通过整个`intersect`过滤器。

**示例：**

```toml
# Adding a negative filter:
filters = { intersect = [ { include = "NS.+" },
                          { exclude = "NSAccidentalClash" } ] }
```

`not`

将过滤器的含义颠倒的运算符。该值必须是单个过滤器：

**示例：**

```toml
# Another way to add a negative filter:
filters = { intersect = [ { include = "NS.+" },
                          { not = { include = "NSAccidentalClash" } } ] }
```

`filter`
`filter-not`（可选）

这些属性必须与其他属性混合使用，即它们不能是`filters`表。它们的值可以是正则表达式或数组，就像`include`和`exclude`属性。

`filter`减少通过主过滤器的集合，以仅包括与给定的单个正则表达式或数组中的任何正则表达式相匹配的名称。

`filter-not`减少通过主过滤器的集合，以仅包括与给定的单个正则表达式或数组中的任何正则表达式不匹配的名称。

`filter`和`filter-not`其实是的简写`intersect`操作与`include`和`exclude`分别过滤。它们可以一起指定。

**举例：**

```toml
# Without filter-not:
filters = { intersect = [ { include = "NS.+" },
                          { exclude = "NSAccidentalClash" } ] }
# With filter-not:
filters = { include = "NS.+", filter-not = "NSAccidentalClash" }

# 'filter' and 'filter-not' can be used together:
filters = { include    = ".*Fizz.+",
            filter     = ".+Buzz.*",
            filter-not = ".*FizzBuzz.*" }
```

#### 类型替换

`[[mappings]]` 是表数组，每项向 Objective-C 类型到另一类型的替换列表追加一条映射。除 `int` 等 C 基本类型外，几乎所有类型的提及均可替换为另一类型。

**示例：**

```toml
# Replace the type id, the root of the Objective-C type hierarchy,
# with NSObjectProtocol everywhere.
[[mappings]]
id = "NSObjectProtocol"
```

#### 配置文件导入

`imports`是一个字符串数组，每个字符串包含另一个配置文件的路径名，其中的设置将添加到当前配置中。的条目`packages`和`mappings`在导入文件中找到的数组将附加到导入文件中存在的数组。

支持嵌套导入，检测循环导入并导致错误。

**示例：**

```toml
import = "../common.toml"
```

## 执行

### 初始化

所有仓颉全局变量都会被初始化，所有仓颉类型的静态初始化器都会在控制第一次到达仓颉代码时被调用，也就是当任何[互操作类](#互操作类) 是第一次在 Objective-C 代码中使用。

初始化代码可以使用镜像类型和/或互操作类，而不是已触发初始化的类型。因此，在这期间，控制权可能会在 Objective-C 和仓颉代码之间来回传递多次。

如果在应用程序启动时发生这种情况，那么它将花费更长的时间，并且应用程序的初始内存占用可能比完全在 Objective-C 中编码相同的应用逻辑更高。这就是预期的行为。

### 终结

#### `dealloc`

互操作类不能重写`dealloc()`的方法`NSObject`。尝试这样做将导致名称冲突和编译时错误，因为启用互操作的代码定义了`dealloc`的包装器对象中的方法来实现自己的目的。

#### 仓颉终结器

镜像类声明不能包含仓颉终结器(`~init()`).

尚不确定[互操作类](#互操作类) 可以包含终结器。

### 异常

Objective-C 和仓颉都具有异常-中断程序正常控制流的事件，通常是为了发出信号，表明发生了非致命的执行错误，需要处理。

在 CJMP 支持的双向互操作场景中，控制可以在嵌套调用链中多次在用不同语言编写的方法/函数之间传递。因此，当在 Objective-C 或仓颉代码中抛出异常时，线程堆栈上可能会穿插着许多 Objective-C 和仓颉代码。这反过来意味着堆栈展开过程可能会跨越语言边界。**重要提示：** 当前版本中，此类跨边界会导致未定义的行为，这意味着从仓颉调用的 Objective-C 方法和函数不能留下任何未捕获的异常，反之亦然。

无法在仓颉代码中 `throw` Objective-C 异常，反之亦然。

### 内存管理

Objective-C 和仓颉对象驻留在不同的堆中。各自的语言运行库管理这两个堆中的每一个。如果对一种语言堆中的对象的引用仍然存在于另一种语言的可访问变量和数据结构中，则互操作库和桥接代码确保它们不会被释放/垃圾收集。

**重要提示：确保跨语言堆一致性的机制有三个重要限制，在使用互操作工具时必须始终理解和记住这些限制：**

1. 在仓颉代码中曾经使用过，然后从任何一种语言中变得不可访问的 Objective-C 对象的释放效率和时机取决于仓颉垃圾回收器。即使从应用程序开发人员的角度来看，引用是短暂的，但这并不意味着当最后一个持有它的变量被赋予新值时，对象会立即被释放。在一个循环中遍历仓颉代码中的大型 Objective-C 数组或集合可能会创建数千个这样的临时固定对象。因此，应用程序内存占用将膨胀，直到调用仓颉垃圾收集器。
2. 由于 Objective-C ARC 和仓颉垃圾回收器各自在各自的托管环境中单独运行，因此跨语言循环引用可能导致内存泄漏。创建这样的引用必须要么完全避免，要么伴随着逻辑，在构成循环的对象从应用程序代码的 Objective-C 和仓颉部分变得不可达之前，打破这样的循环。
3. 从当前版本开始，镜像类型和互操作类的值不得存储在全局变量或静态变量中，也不得存储在此类变量所引用的任何数据结构中。因此，将外部类型的值转换为`Object`和`Any`是禁止的。

    正在就取消这一限制进行工作。

    **警告：** `cjc`编译器并不能完全执行上述限制，因此需要严格的编程纪律。不遵守该纪律可能导致程序异常终止。

### 线程

仓颉 `spawn`可以不受任何限制地使用 Objective-C 镜像类型。
