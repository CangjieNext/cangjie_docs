# 仓颉-Java 互操作

**注意：** Java 互操作特性为实验性功能，仍在持续改进中。

**注意：** 请优先查阅英文版本文档。

## 简介

**仓颉多平台**技术使仓颉开发者能够将代码集成到新的 Android/iOS 应用中，或逐步用仓颉代码替换现有应用中的 Java/Objective-C 部分。实现跨语言、跨运行时互操作的核心机制是*[镜像类型](#镜像类型)*，它将一种语言的类型暴露给另一种语言。

在仓颉侧，镜像类型支持以常规仓颉语法继承 Java/Objective-C 类并重写方法，以及实现 Java 接口和 Objective-C 协议。那些扩展或实现镜像类与接口/协议的仓颉类，会作为相应平台原生语言的类暴露回 Java/Objective-C。这使得应用的 Java/Objective-C 部分与仓颉部分能够无缝衔接，包括在仓颉代码中使用目标操作系统的 API。

### 挑战与解决方法

Java、Objective-C 和仓颉都是支持继承与多态的面向对象语言，但它们在语义、对象模型和执行模型上的差异，使得无法直接在 Java 或 Objective-C 代码中使用仓颉对象，反之亦然。

三种语言都拥有支持自动内存管理、线程、异常处理等底层能力的托管运行时，但实现方式各不相同。若让两套独立设计的复杂语言运行时彼此感知，可能使整个系统的复杂度超出可理解范围。

仓颉与 Java 的互操作通过将双方都视为底层语言来实现：应用的仓颉部分与 Java 部分通过 Java 本地接口（JNI）相互可见。JNI 最初用于在 C/C++ 等语言中编写 Java `native` 方法，功能丰富但层级较低，手写 `native` 方法也颇为繁琐。CJMP 则自动处理 JNI 的复杂细节。

Objective-C 运行时模块 API 在 iOS 上承担类似角色，同样用于在 Objective-C 与其他语言之间构建桥接层；与 JNI 一样，繁琐部分由 CJMP 负责。

## 关键概念

### 镜像类型

将仓颉与 Java 视为一对互操作语言时，仓颉中定义的镜像类型 _`T'`_ 表示已有的 Java 类型 _`T`_，使仓颉开发者能够使用类型 _`T`_（可能有一定限制）。

两种语言中本质相同的布尔类型与数值类型会自然互为镜像：Java 类型 `int` 的仓颉镜像类型是 `Int32`，依此类推。

对于类、接口或数组等用户自定义类型，镜像类型取另一种语言中最接近的等价物。例如，仓颉枚举与 Java 枚举类差异很大，后者最好[用仓颉类近似](#枚举类)。

镜像类型暴露原用户自定义类型中可访问且能在另一种语言中使用的成员与构造函数。例如，Java 枚举类的构造函数仅用于初始化，无需暴露给仓颉。

通常可使用 Android 版仓颉 SDK 附带的独立[镜像生成器](#java-镜像生成器参考)，自动获得 Java 类型及其依赖的镜像类型定义。

#### 将 Java 类型镜像为仓颉类型

`cjc` 编译器会将 Java 镜像类型的使用替换为相应胶水代码，因此重要的是类型名称及其可访问成员的名称与类型。Java 类型的镜像只包含成员声明：构造函数与成员函数/属性无函数体，成员变量无初始化器；`private` 与包私有成员亦被省略。

为使这一仓颉语法扩展生效，每个镜像类型须标注 `@JavaMirror`，以便编译器区分镜像类型声明与普通仓颉类型定义。

例如，以下 Java 类的镜像类：

```java
public class Node {
    public static final int A = 0xDeadBeef;
    private int _id;
    public Node(int id) { _id = id; }
    public int id() { return _id; }
}
```

可能看起来像这样：

```cangjie
@JavaMirror
public open class Node {
    public static let A: Int32
    public init(id: Int32)
    public open func id(): Int32
}
```

`java.lang.Object`、`java.lang.String` 以及数组等若干基础 Java 类型在互操作库中有[预定义镜像](#互操作库-api-参考)。

### 互操作类

_互操作类_本质上是派生自一个或多个[镜像类型](#镜像类型)的仓颉类，可在仓颉与 Java 两侧使用。其所有构造函数与非继承的 `public` 成员函数通过 `cjc` 自动生成的_包装类_暴露给 Java；包装类本身不定义其他可由用户调用的方法或构造函数，但从 Java 超类型继承的方法可在 Java 与仓颉代码中调用。

例如，编译以下互操作类时：

```cangjie
@JavaImpl
public class BooleanNode <: Node {
    private let flag: Bool
    public init(id: Int32, flag: Bool) {
        super.init(id)
        this.flag = flag
    }
    public func isFlagged(): Bool {
        flag
    }
}
```

`cjc`编译器还将生成一个类似于以下的 Java 源代码文件：

```java
public class BooleanNode extends Node {
    /* 胶水代码 */
    public BooleanNode(int id, boolean flag) {
        /* 胶水代码，构造一个 Java 的 BooleanNode 包装类实例，
         * 并将其与仓颉侧的 BooleanNode 实例关联起来
         */
    }
    public boolean isFlagged() {
        /* 胶水代码，调用该 Java 的 BooleanNode 包装类实例所关联的
         * 仓颉 BooleanNode 实例的'isFlagged'实例成员函数，并返回调用结果
         */
    }
    /* 其他胶水代码 */
}
```

此后，Java 与仓颉代码均可实例化互操作类 `BooleanNode`，调用其 `public` 实例成员函数 `id()`（继承自 Java 类 `Node`）和 `isFlagged()`，并将实例分别转换为 `Node` 及其镜像类型等。

### 外部类型

[镜像类型](#镜像类型)与[互操作类](#互操作类)并非在其定义语言中完全“原生”。类比而言，它们分别像临时访客与工作签证持有者，本文统称为_外部类型_。

### Java 兼容类型

以下仓颉类型称为_Java 兼容_类型：

* 与 Java 基本类型直接对应的值类型（包含 `Int16`，但不包含 `UInt8`）
* [外部类型](#外部类型)
* 形如 `Option<`_`T`_`>` 的类型，其中 _`T`_ 为[外部类型](#外部类型)（理由见 [_`null` 处理_](#null-处理)）

互操作库中的特殊泛型镜像类型 [`JArray<T>`](#自动字符串转换) 表示 Java 数组，其类型变元 `T` 须为 Java 兼容类型。

外部类型的 `public` 成员函数的参数与返回值，以及其 `public` 构造函数的参数，均只能使用 Java 兼容类型。

互操作类的成员变量可使用任意类型，即便为 `public` 也不会暴露给 Java；`public` 成员属性则会暴露，例如：

```cangjie
@JavaImpl
class WeightedNode <: Node {
    public let weight: Float64      // 不暴露给 Java
    public init(weight: Float64) {
        this.weight = weight
    }
}
```

```cangjie
@JavaImpl
class ColoredNode <: Node {
    private let _color: Int32
    public prop color: Int32 {     // 暴露给 Java 为方法 'int getColor()'
        get() { _color }
    }
    public init(color: Int32) {
        _color = color
    }
}
```

为方便起见，仓颉类型 `String` 与 Java 具有一定兼容性。详见[自动字符串转换](#自动字符串转换)。

## 在仓颉中使用 Java

要实现 Android 应用程序的 Java 和仓颉部分之间的互操作，需要执行以下步骤：

1. 按照 Java 类和方法来设计互操作层 API。

   开发者 → `interop layer design`（Java 伪代码）

2. 为互操作层设计中使用的任何现有 Java 类和接口生成镜像声明。

   `.class` → 镜像生成器 → `.cj`（镜像）

3. 用仓颉编写构成互操作层的类。根据需要使用的镜像 Java 类型：创建实例、调用方法等。

   `interop layer design` + `.cj`（镜像） → 开发者 → `.cj`（互操作层）

4. 使用 `cjc` 一起编译互操作类和镜像类型声明。`cjc` 将生成：

   * 所有镜像类型使用的必要胶水代码。
   * 互操作层 Java 部分的实际 Java 源代码。

   `.cj`（镜像 + 互操作层） → `cjc` → `.so` + `.java`（互操作层）

5. 添加到您的 Android 项目：

   * `cjc` 生成的 `.java` 文件
   * `cjc` 生成的 `.so` 文件
   * 来自仓颉 SDK 的运行时库（`.so` 和 `.jar`）

   然后在 Java 源代码中插入必要的互操作层使用并重建项目。

   Android 项目 + `.java`, `.jar`, `.so` → Android 工具链 → `.apk`

章节 [初始互操作类创建工作流](#初始互操作类创建工作流) 和 [从仓颉调用 Java](#从仓颉调用-java) 通过端到端示例详细描述了上述过程。

### 初始互操作类创建工作流

#### 步骤 1：设计互操作层

本步骤从 Java 代码视角设计一个或多个互操作类的 API。对每个互操作类，需确定：

* 所属 Java 包；
* 继承的 Java 类（默认 `java.lang.Object`）；
* 实现的 Java 接口（如有）；
* 具有的 `public` 方法及/或构造函数（仅需确定参数类型、方法名与返回类型；实现将在仓颉中编写）。

另请参见[互操作类的特性与限制](#互操作类的特性与限制)。

**示例：**

假设要通过 `static` 方法 `m()` 将控制从 Java 交给仓颉：该方法接受 `com.example.a.A`、`java.lang.String` 和 `int`，返回 `com.example.b.B`；方法属于继承 `Object`、位于包 `cjworld` 的类 `Interop`。

即，步骤 4 应生成的 Java 源文件内容如下：

```java
package cjworld

import com.example.a.A;
import com.example.b.B;

public class Interop {
    /* 胶水代码 */
    public static B m(A a, String s, int i) {
        /* 调用仓颉侧静态成员函数`m`实现逻辑的胶水代码 */
    }
    /* 其他胶水代码 */
}
```

#### 步骤 2：生成镜像类型声明

需要为互操作类依赖的所有 Java 引用类型获取[镜像类型](#镜像类型)声明：超类型、方法与构造函数的参数类型等，以及这些类型可能的依赖。

**注意：** `java.lang.Object`、`java.lang.String` 以及表示 Java 数组的泛型镜像类由[互操作库](#互操作库-api-参考)提供。若互操作类的方法与构造函数仅传递或接收基本 Java 类型、`java.lang.Object`、`java.lang.String` 及前述类型的数组，可跳过本步骤。

使用仓颉 SDK 中的 [Java 镜像生成器](#java-镜像生成器参考)生成镜像类型声明，如下所示。

**命令行：**

```bash
java -Dpackage.mode=true -Dpackage.name=package-name \
    -jar ${CANGJIE_HOME}/tools/bin/java-mirror-gen.jar \
    --boot-class-path path-to-android-jar \
    --class-path full-application-classpath \
    --d output-directory \
    names-of-mirrored-types
```

或

```bash
java -Dpackage.mode=true -Dpackage.name=package-name -Djar.mode=true \
    -jar ${CANGJIE_HOME}/tools/bin/java-mirror-gen.jar \
    --boot-class-path path-to-android-jar \
    --class-path full-application-classpath \
    --d output-directory \
    jar-file
```

* `package-name`：所有镜像类型目标仓颉包名。
* `path-to-android-jar`：所用 Android SDK 中 `android.jar` 的路径，例如 `${ANDROID_SDK}/platforms/android-35/android.jar`。
* `full-application-classpath`：应用构建时的完整类路径，_须再次包含 `android.jar`_。
* `output directory`：存放镜像类型声明仓颉源文件的目录，例如 `./src/cj`。
* `names-of-mirrored-types`：互操作类设计依赖的 Java 引用类型完全限定名（空格分隔），不含 `java.lang.Object`、`java.lang.String` 及数组。
* `jar-file`：单个 jar 路径；将镜像其中所有 `public` 类与接口的 `.class`，以及沿 `full-application-classpath` 找到的依赖。

**示例：**

继续上面的例子，我们注意到我们的类`cjworld.Interop`依赖于：

* `java.lang.Object`作为超类；
* `com.example.a.A`，`java.lang.String`，和`int`作为参数类型；
* `com.example.b.B`作为返回值。

无需镜像 `int` 等基本类型；`java.lang.Object` 与 `java.lang.String` 已预置镜像。仅需镜像两个 `com.example` 类。假设希望它们出现在仓颉包 `javaworld` 中。

虚构应用类路径下的镜像生成器命令行：

```bash
java -Dpackage.mode=true -Dpackage.name=javaworld \
    -jar ${CANGJIE_HOME}/tools/bin/java-mirror-gen.jar \
    --boot-class-path ${ANDROID_SDK}/platforms/android-35/android.jar \
    --class-path ${ANDROID_SDK}/platforms/android-35/android.jar:./App.jar \
    --d ./src/cj \
    com.example.a.A com.example.b.B
```

这将生成文件`src/cj/javaworld/src/A.cj`和`src/cj/javaworld/src/B.cj`，以及这两个 Java 类型可能具有的任何依赖项的镜像类型声明。

#### 步骤 3：编写互操作类

对步骤 1 中设计的每个 Java 类骨架，按下列方式编写仓颉类：

1. 使用相应包名与类名（Java 包装类将具有相同完全限定名）。
2. 导入 `java.lang.*`。
3. 导入步骤 2 生成的必要镜像类型（暂不导入其依赖）。
4. 为类添加 `@JavaImpl` 注解。
5. 继承目标 Java 类的镜像（默认继承 `java.lang.Object` 的内置镜像）。
6. 分别用 `JObject`、`JString`、`JArray<T>` 代替 `java.lang.Object`、`java.lang.String` 与 Java 数组类型。

类型映射（`T'` 为对应仓颉值类型或镜像类型）：

| Java 类型 (`T`)   | 仓颉类型 (`T'`)                                    |
| ------------- | -------------------------------------------- |
| `boolean`     | `Bool`                                       |
| `byte`        | `Int8`                                       |
| `short`       | `Int16`                                      |
| `char`        | `UInt16`                                     |
| `int`         | `Int32`                                      |
| `long`        | `Int64`                                      |
| `float`       | `Float32`                                    |
| `double`      | `Float64`                                    |
| `Object`      | `JObject`或`?JObject`^*^                     |
| `String`      | `JString`，`?JString`，`String`或`?String`^\*†^ |
| `class C`     | `C'`或`?C'`^*^                               |
| `interface I` | `I'`或`?I'`^*^                               |
| `T[]`         | `JArray<T'>`或`?JArray<T'>`^*^               |

^*^ 对可能接收或持有 Java `null` 的镜像类型与互操作类，在参数、返回值与局部变量处使用 `?<T'>`（`Option<T'>`）。

^†^ 在暴露给 Java 的互操作类成员与构造函数定义中使用仓颉 `String` 的细则，见[自动字符串转换](#自动字符串转换)。

用 `Unit` 作为返回类型表示 Java `void` 方法。

另请参见[互操作类的特性与限制](#互操作类的特性与限制)。

**示例：**

延续上例，方法 `m()` 的互操作类如下：

```cangjie
package cjworld

import java.lang.*
import javaworld.*

@JavaImpl
public class Interop {
    public static func m(a: ?A, s: ?JString, i: Int32): ?B {
        /* 暂为占位实现 */
        B()    // 假设 B 有无参构造函数
    }
}
```

若 `m()` 无需向 Java 调用方返回 `null`，可去掉返回类型的 `?`。

#### 步骤 4：编译互操作类

**注意：** 请确保已安装 [Android NDK](https://developer.android.com/ndk)，且 `ANDROID_NDK_HOME` 环境变量指向其安装路径。

首先编译镜像类型声明，然后编译互操作类(假设它们在不同的包中，例如。`javaworld`和`cjworld`).

命令行：

```bash
cjc --output-type=dylib \
    --target=aarch64-linux-android31 \
    -p source-directory \
    -ljava.lang -ljava.internal \
    --output-javagen-dir=java-output-directory \
    --sysroot=${ANDROID_NDK_HOME}/toolchains/llvm/prebuilt/linux-x86_64/sysroot \
    -B ${ANDROID_NDK_HOME}/toolchains/llvm/prebuilt/linux-x86_64/bin
```

其中

`source-directory`是包含互操作类和镜像类型声明的源代码的目录的路径名。

`java-output-directory`是将生成的 Java 源文件放置到的目录的路径名。

输出是一个`.so`文件，其中包含为互操作类和 Java 源文件(`.java`)的 Java 包装器。

**示例：**

```bash
cjc --output-type=dylib \
    --target=aarch64-linux-android31 \
    -p src/cjworld \
    -ljava.lang -ljava.internal \
    --output-javagen-dir=src/java \
    --sysroot=${ANDROID_NDK_HOME}/toolchains/llvm/prebuilt/linux-x86_64/sysroot \
    -B ${ANDROID_NDK_HOME}/toolchains/llvm/prebuilt/linux-x86_64/bin
```

编译器将生成两个文件：`libcjworld.so`和`src/java/cjworld/Interop.java`.

#### 步骤 5：整合所有产物

1. 将下列文件加入 Android 项目：

    * 上一步生成的 Java 源文件——按包名放入 `src/main` 下相应源码目录。
    * 上一步生成的 `.so` 文件——放入 `src/main/jniLibs/arm64-v8a`（不存在则创建）。
    * `$CANGJIE_HOME/runtime/lib/` 下对应子目录（如 `linux_android31_aarch64_cjnative/`）中的全部 `.so`——同样放入 `src/main/jniLibs/arm64-v8a`。
    * Android NDK 中的 `libc++_shared.so`——同样放入 `src/main/jniLibs/arm64-v8a`（位于 NDK 根目录下 `toolchains/llvm/prebuilt/`_`host`_`/sysroot/usr/lib/aarch64-linux-android/`，_`host`_ 为构建主机标识，如 `linux-x86_64`）。
    * 将 `$CANGJIE_HOME/lib/library-loader.jar` 添加为依赖。

2. **重要：须在 APK 中按传统方式压缩全部 `.so` 文件，否则加载仓颉库时应用会崩溃。**

   在应用 Gradle 脚本（通常为 `build.gradle.kts`）的 `android {}` 块中加入（若尚未配置）：

   ```text
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

3. 重新构建项目以确认配置正确，必要时尝试部署。
4. 在 Java 代码中加入对互操作类的使用，并再次构建项目。

**示例：**

在 Java 代码中调用 `Interop.m()`，将控制交给互操作类中的仓颉实现：

```java
.  .  .
    B b = Interop.m(new A(), "Test", 0);
       .  .  .
```

### 从仓颉调用 Java

按[上一节](#初始互操作类创建工作流)设计、构建并集成互操作层后，可在互操作类的成员函数中使用 Java 类型。类型映射与上文相同：

| 仓颉类型 (`T'`)                  | Java 类型 (`T`) |
| -------------------------- | ----------- |
| `Bool`                     | `boolean`   |
| `Int8`                     | `byte`      |
| `Int16`                    | `short`     |
| `UInt16`                   | `char`      |
| `Int32`                    | `int`       |
| `Int64`                    | `long`      |
| `Float32`                  | `float`     |
| `Float64`                  | `double`    |
| `JObject`或`?JObject`       | `Object`    |
| `JString`或`?JString`       | `String`    |
| `T'`或`?T'`                 | `T`^*^     |
| `JArray<T'>`或`?JArray<T'>` | `T[]`^†^    |

^*^`T'`必须是 Java 类型的镜像类型`T`或互操作类，其 Java 包装类的源代码`T`由自动生成`cjc`.

^†^`T'`必须是镜像类型、互操作类或上面列出的值类型之一，例如。`Int32`.

**限制：**

* Java 类型的可变参数`T`被镜像为类型的常规参数`?JArray<T'>`.为了将任何参数传递给这样的参数，代码必须显式地创建并初始化一个`JArray<T'>`在调用这样的方法或构造函数之前。

#### 步骤 0：正常构建 Android 应用

#### 步骤 1：生成镜像类型声明

如果您只想调用互操作类的成员函数，它们的超类和/或已经为其生成了镜像声明的类型，例如互操作类参数或返回值的类型，请跳过此步骤。

**命令行：**

```bash
java -Dpackage.mode=true -Dpackage.name=package-name \
    -jar ${CANGJIE_HOME}/tools/bin/java-mirror-gen.jar \
    --boot-class-path path-to-android-jar \
    --class-path full-application-classpath \
    --d output-directory \
    names-of-mirrored-types
```

或

```bash
java -Dpackage.mode=true -Dpackage.name=package-name -Djar.mode=true \
    -jar ${CANGJIE_HOME}/tools/bin/java-mirror-gen.jar \
    --boot-class-path path-to-android-jar \
    --class-path full-application-classpath \
    --d output-directory \
    jar-file
```

其中

* `<package-name>`是所有镜像类型的仓颉包的期望名称。
* `path-to-android-jar`是的路径名`android.jar`你正在使用的 Android SDK 中的文件，例如。`${ANDROID_SDK}/platforms/android-35/android.jar`.
* `<full-application-classpath>`是应用程序在构建期间使用的完整类路径，包括`android.jar`.
* `<output directory>`是包含镜像类型声明的仓颉源文件将放置的目录的路径名，例如`./src/cj`.
* `<names-of-mirrored-types>`是要在互操作类的代码中使用的所有 Java 引用类型的空格分隔的完全限定名，此外`java.lang.Object`，`java.lang.String`和数组类型。
* `<jar-file>`是单个 jar 文件的路径名。`public`类和接口，`.class`包含的文件，以及在`<full-application-classpath>`.

**示例：**

继续示例，从[上一节](#初始互操作类创建工作流)，假设我们想要我们的函数`Interop.m()`来调用方法`String g(A a, int i)`类的`com.example.c.C`，其中`A`是类型`com.example.a.A`我们之前已经镜像过的：

```java
package com.example.c;

import com.example.a.A;

public class C {
    public static String g(A a, int i) {
        /*一些返回字符串的Java代码*/
    }
}
```

我们重新运行镜像生成器，通过`com.example.c.C`作为一个额外的（不是唯一的!）类型名称镜像：

```bash
java -Dpackage.mode=true -Dpackage.name=javaworld \
    -jar ${CANGJIE_HOME}/tools/bin/java-mirror-gen.jar \
    --boot-class-path /home/user/Android/Sdk/platforms/android-35/android.jar \
    --class-path /home/user/Android/Sdk/platforms/android-35/android.jar:App.jar \
    --d ./src/cj \
    com.example.a.A com.example.b.B com.example.c.C
```

此命令将生成具有镜像类型声明的相同文件，加上`src/javaworld/src/C.cj`和具有镜像类型声明的文件，该类型可能具有的任何先前未镜像的依赖项。

文件`src/cj/javaworld/src/C.cj`将看起来像这样：

```cangjie
package javaworld

import java.lang.*

@JavaMirror["com.example.c.C"]
public class C {
    public static func g(a: ?A, i: Int32): ?JString
}
```

#### 步骤 2：导入镜像类型并编写代码

确保所有涉及的镜像类型（s）都被导入，然后实现你的 interop 类的构造函数和成员函数，像操作 Java 类型一样操作它们。

**示例：**

继续上一节的示例，我们可以实现`cjworld.Interop.m()`使用镜像类型`javaworld.C`：

```cangjie
package cjworld

import java.lang.*
import javaworld.A
import javaworld.B
import javaworld.C

@JavaImpl
public class Interop {
    public static func m(a: ?A, s: ?JString, i: Int32): ?B {
        let s1: JString = match (a) {
            case Some(aa) => C.g(aa, i) ?? JString("")
            case None => JString("")
        }
        B(s1)  //假设有一个B(String)构造函数
    }
}
```

#### 步骤 3：重新编译仓颉部分

请参见[步骤 4](#步骤-3重新编译仓颉部分)的 interop 类创建工作流的详细信息和示例。

只要在前面的步骤中没有改变 interop 类的 public 接口（es），只需要更新`.so`文件。生成的 Java 源代码应该与之前生成的相同。

#### 步骤 4：更新并重新构建 Android 项目

复制`.so`文件，如果适用，`.java`将上一步更新/生成的文件转到你的 Android 项目中，并重新构建它。

请参见[步骤 5](#步骤-5整合所有产物)的 interop 类创建工作流的详细信息和示例。

### 互操作类的特性与限制

1. 互操作类必须是镜像类的直接子类。默认情况下，互操作类将继承镜像类[`java.lang.JObject`](#互操作类的特性与限制)，不`std.core.Object`.
2. 一个 interop 类可以实现一个或多个镜像接口，但决不能实现常规的仓颉接口。相反，传统的仓颉类型可能不实现或继承镜像的 Java 接口。
3. 互操作类不能声明为`open`或`abstract`，不能使用扩展`extend`、和可能不是通用的。
4. 一个 interop 类可以引入任何仓颉类型的新实例字段，因为它们不暴露给 Java，并重写其镜像超类的成员函数。
5. 互操作类的构造函数可以使用`super()`，但对实例成员函数调用有与传统仓颉构造函数相同的限制，以及需要初始化所有新引入的成员变量。
6. 互操作类的实例成员函数可以调用该互操作类从其镜像超类继承的实例成员函数，和/或使用`super.`来调用 interop 类重写的超类的成员函数。
7. 的签名`public`互操作类的构造函数和成员函数只能使用（a）镜像类型或互操作类本身的类型，(b)与 Java 基本类型 100%相似，或（c）类型`String`。此限制也适用于`public`属性。有关详细信息，请参阅中的类型映射表[从仓颉调用 Java](#从仓颉调用-java)和[自动字符串转换](#自动字符串转换)下面的小节。

以下两个限制是 Android/JVM 特定的：

1. 所有镜像类型和互操作类的 Java 对应类都必须由同一个类加载器加载。
2. 与 Java 和其他 JVM 语言不同，仓颉不允许包之间存在循环导入依赖。这对镜像生成过程提出了挑战。请参考[循环导入依赖项处理](#循环导入依赖处理)详情请参见。

#### 自动字符串转换

Java 和仓颉字符串类型`java.lang.String`和`std.core.String`、不兼容二进制。因此，需要进行复制转换，以便使用一种语言编写的代码能够处理源自另一种语言的字符串数据。内置镜像类型[`java.lang.JString`](#自动字符串转换)通过提供一个特殊的构造函数来促进这种转换，该构造函数接受一个仓颉字符串，并使用它的 UTF-8 字符数据来构造包含 UTF-16 编码中相同字符的 Java 字符串，以及一个成员函数`toString()`执行相反的情况，并返回一个仓颉字符串：

```java
public class J {
    public static String s2s(String s) { ... }
}
```

```cangjie
@JavaMirror
public class J {
    public static func s2s(s: ?JString): ?JString
}

   .  .  .

    let s: String = J.s2s(JString("Cangjie string")).getOrThrow().toString()
```

任何将 Java 字符串值传递给常规的仓颉函数以进行进一步处理和/或将仓颉字符串传递给 Java 的仓颉代码，如果不使用表单的调用，肯定会看起来更干净、更紧凑_`Java-string`_`.toString()`和`JString(`_`Cangjie-string`_`)`但是，在跨语言边界时自动转换所有 Java 字符串值可能会在某些场景下导致大量的 CPU 和内存开销。如果仓颉代码并不实际操作 Java 字符串，而只是将其传递回 Java，或者只在极少数情况下访问它，或者根本不使用它，那么这种转换就是一种计算资源的浪费，这在移动应用程序中是不可取的。

相反，互操作类编写器可以选择性地对需要具有 Java 类型的特定构造函数/成员函数参数、成员函数返回值和成员属性启用这种自动转换`String`当它们暴露在 Java 中时。这通过允许这些实体被声明为具有仓颉类型来实现`String`而不是`JString`.唯一的限制是这样的成员函数不能重写其镜像 Java 超类型的方法（见下面的注释）。生成的 Java 包装器使用 Java`String`类型，当从 Java 调用包装类的方法和构造函数时，桥接代码会自动在这两种类型之间转换字符串值。

如往常一样，如果支持接收/返回`null`值是必需的，类型`?String`必须使用而不是`String`，请参见[空处理](#null-处理)的详细信息。

**注意：**

1. `String`和`JString`是不在子类型关系中的不同类型。这意味着重写其镜像 Java 超类型方法的互操作类的成员函数应该使用相同的参数和返回值类型。`?JString`为`override`修改程序以按预期工作：

    ```cangjie
    @JavaMirror
    public class J {
        public func f(s: ?JString): Unit
    }
    
    @JavaImpl
    public class CJ <: J {
        override public func f(s: ?String): Unit {}   //报错
        public func f(s: ?String): Unit {}            //重载，而不是覆盖
        override public func f(s: ?JString): Unit {}  //好的
    }
    ```

    虽然手动更换了`JString`与`String`在镜像类型声明中，由于上述原因，不鼓励这种做法，因为缺少子类型可能会引入意外的、难以诊断的覆盖/重载歧义，如果这种替换没有在所有子类型中 100%一致地完成。
2. `String`不支持作为的类型参数[`java.lang.JArray<T>`](#自动字符串转换)，所以 Java 字符串数组必须映射到`JArray<JString>`，或者更有可能是`?JArray<?JString>`.

## Java 到仓颉的映射

当前版本的镜像生成器会执行以下 Java →仓颉转换。

### 一般注意事项

镜像生成器以 Java _类_文件为输入。Java 编译器未从源码写入类文件、或随后被剥离的信息，镜像生成器均无法获得；最典型的是[泛型](#泛型)与方法参数名。

### 名称

Java 类型、字段和方法的原始名称被最大可能地保留。如果由于下面列出的原因之一而无法保留原始名称，则通过注释将其传播到仓颉编译器。

* 与仓颉关键字冲突的 Java 标识符，如"`func`","`main`"或`Int32`都用反号圈起来``` `` ```形成原始的仓颉标识：

    ```java
    public static final long Int32 = 0xffff_ffff;
    ```

    ```cangjie
    public static let `Int32`: Int64
    ```

* Java 标识符可能包含仓颉标识符中不允许使用的字符，最明显的是美元符号`$`，用于嵌套 Java 类型的二进制名称。这样的字符被下划线代替`_`：

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

* 尽管它被认为是不好的做法，但 Java 类型可能有一个字段、一个成员类型和一个方法共享同一个简单名称（标识符）。这很管用，因为总是可以通过语法来确定名称的含义(只有方法名后面可以跟"`(`")或来自上下文。此外，在 Java 中，只要一个类型的实例方法和静态方法的签名不同，它们就可以具有相同的名称。

    然而，在仓颉中，在给定作用域中声明的所有成员变量和非重载函数必须具有独特的名称。(仓颉中没有成员类型，所以名称与成员类型的冲突永远不会发生，因为它们是[镜像到顶级类型](#类与接口)。特别是实例成员函数和静态成员函数不能有相同的名称。

    镜像生成器因此附加了"`_`_`type-name`_的名称，实例变量的名称和`Static`"的名字`static`方法，如果它们的原始 Java 名称与其他字段/方法名称冲突。它保留原始名称作为`@ForeignName`注释：

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

    翻译为

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

* Java 包的名称在实践中不能保留，因为 Java 中禁止包之间的循环导入依赖，请参阅[循环导入依赖项处理](#循环导入依赖处理)的详细信息。

### 基本类型

Java 基元类型镜像到相应的值类型：

| Java 类型 | 仓颉类型 |
| --------- | --------- |
| `boolean` | `Bool`    |
| `byte`    | `Int8`    |
| `short`   | `Int16`   |
| `char`    | `UInt16`  |
| `int`     | `Int32`   |
| `long`    | `Int64`   |
| `float`   | `Float32` |
| `double`  | `Float64` |

### 类与接口

Java 类和接口定义分别镜像到带有注释的类和接口声明中`@JavaMirror`.该注解的值是一个字符串，它保留了镜像 Java 类型的原始完全限定名。镜像类型的简单名称将被保留，除非它们包含仓颉标识符中不允许的字符。这样的字符，最明显的是美元符号`$`，在 Java 类文件名中的出现通常表示相应的类型是嵌套类型，用下划线代替`_`.

_Java 类和接口类型的使用作为镜像字段的类型，和/或作为镜像方法和构造函数的参数和返回值的类型，可以包装在_`Option<T>`(见[空处理](#null-处理)了解详细信息。)

`@JavaMirror` 注解声明与传统的仓颉类/接口定义有以下几个方面的不同：

* Java 镜像类层次结构的根不是`std.core.Object`，而是一个内置的镜像类[`java.lang.JObject`](#互操作类的特性与限制)，它是的直接子类`std.core.Object`.
* 的镜子`java.lang.String`也是内置的，它的名字是[`java.lang.JString`](#自动字符串转换)。
* 仅镜像符号信息。省略了变量初始化器和函数/构造函数体。

**示例：**

例如，以下 Java 类的镜像类：

```java
public class Node {
    public static final int A = 0xDeadBeef;
    private int id;
    public Node(int id) { this.id = id; }
    public int id() { return id; }
}
```

可能看起来像这样：

```cangjie
@JavaMirror["Node"]
public open class Node {
    public static let A: Int32
    public init(id: Int32)
    public func id(): Int32
}
```

只有`public`Java 类和接口是镜像的。镜像的非`final`类被修改为`open`.修饰符`sealed`和`non-sealed`被忽略，以及旧修改器`strictfp`.

`private`和包私有成员和构造函数，以及静态和实例初始化器都没有镜像。

如果 Java 类型成员及其镜像的名称因下列原因之一而不同[名称](#名称)原始 Java 成员名称通过的值传播到仓颉`@ForeignName`镜像成员上的注释：

```java
CurrencyAmount priceInUS$Per(WeightUnit wu) { ... }
```

```cangjie
@ForeignName["priceInUS$Per"]
    public open priceInUS_Per(arg0: WeightUnit): CurrencyAmount
```

> **注意：访问修饰符的含义**`protected`在 Java 和仓颉中是不同的。
>
> 在 Java 中，访问一个`protected`一个类的成员或构造函数可以从同一包中的任何地方以及从定义在其他包中的子类中获得。
>
> 在仓颉中，该修饰符还允许从子包和同一模块内的任何包进行访问。
>
> 通常情况下，这应该不会造成问题。

**字段镜像到各自镜像类型的成员变量中。字段名称只要不存在**[冲突](#名称)还有其他成员的名字。修改器`public`，`protected`和`static`都被保留下来。修改器`transient`和`volatile`都被忽略。`final`Java 字段镜像到`let`成员变量，非`final`\-进入`var`成员变量。省略了变量初始值设定项。

**方法被镜像到成员函数中，并使用相应的镜像类型替换参数类型和返回值类型。的镜像 _`void`_ 方法有`Unit`返回类型。实例方法名被保留。静态方法名被保留，只要它们不[冲突](#名称)使用实例方法名。修改器`public`，`protected`和`static`都得以保留。修改器`native`和`synchronized`被忽略，以及旧修改器`strictfp`.镜像的非`final`方法被修改为`open`.最后一个参数 _`T`_`...`_`name`_ 的可变属性方法被镜像，就好像它的类型是 _`T`_`[]`.

**构造函数被镜像到 _`init`_ 用各自的镜像类型替换参数类型的构造函数。这包括可能已经隐式声明的默认构造函数。修改器`public`和`protected`都被保留下来。最后一个参数 _`T`_`...`_`name`_ 的可变属性构造函数被镜像，就好像它的类型是 _`T`_`[]`.

**注意：**

1. 镜像类可以没有主构造函数。
2. 镜像类，不包含`init`构造函数不会得到一个隐式定义的默认的，这与传统的仓颉类不同，因此不能通过调用构造函数来实例化。对于自动生成的镜像类，没有构造函数通常意味着镜像的 Java 类只声明`private`或包私有构造函数，以防止其被任意代码实例化。另请参见[枚举类](#枚举类)。
3. Java 镜像生成器以类文件作为输入，而类文件中经常缺少方法/构造函数参数的名称。在这种情况下，镜像生成器将为它们指定名称`arg0`，`arg1`、等等。`javac`编译器选项`-parameters`强制保留参数名称，但只适用于类，不适用于接口。调试信息生成选项也是如此`-g`/`-g:vars`.

**成员类型被镜像到相应的顶级类型，因为仓颉不支持类型嵌套。成员类型镜像的名称源自原始成员类型的二进制名称，该名称由其直接封闭类型的二进制名称组成，后跟一个美元符号**`$`，后跟成员类型本身的简单名称。但是，在仓颉识别符中不允许使用美元符号，因此它被替换为下划线`_`(另见[名称](#名称)。修饰符`public`和`protected`都被保留下来。修改器`static`被忽略。`init`镜像内部类的构造函数有一个额外的参数用于传递封闭实例（该参数在 Java 中是隐式的）：

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

@JavaMirror["Outer$Static"]       //保留原始二进制名称
public open class Outer_Static {  //'$'替换为'_'
    public init()
}

@JavaMirror["Outer$Inner"]       //保留原始二进制名称
public open class Outer_Inner {  //'$'替换为'_'
    public init(p0: ?Outer)      //用于封闭实例的额外参数
}
```

在所有方法和构造函数的镜像中都省略了实体，因此它们看起来都像普通仓颉代码中的抽象成员函数。这将导致以下语法更改：

* 修改器`abstract`类方法上的方法被保留，否则就无法区分抽象和具体 Java 方法的镜像：

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

* 出于同样的原因，默认接口方法的镜像会被注解为`@JavaHasDefault`.

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

在参数数量可变的方法和构造函数中，`, ...`被忽略。

#### 镜像类型继承

镜像类和接口形成单独的子类型层次结构，这意味着：

* Java 镜像类层次结构的根不是`std.core.Object`，而是一个内置的镜像类[`java.lang.JObject`](#互操作类的特性与限制)。
* 镜像接口可以继承其他镜像接口，反映了原 Java 接口之间的继承关系。镜像接口可以不继承常规仓颉接口，反之亦然。
* 镜像类可以继承其他镜像类，反映了原始 Java 类之间的继承关系。镜像类不能继承普通仓颉类，反之亦然。
* 镜像类可以实现镜像接口，但不能实现常规的仓颉接口。特别是，它们不实现接口`Any`.普通仓颉类可能不实现镜像接口。
* 两个镜像类都不能使用扩展`extend`，也可以通过镜像接口扩展任何其他类型。
* 在 Java 中，所有接口都是`java.lang.Object`类。因为在 Java 中只有类可以实现接口。后者在仓颉就不是这样，所有的接口都是内置的子类型`Any`接口，它不是的子类型`std.core.Object`.因此，镜像接口不是的子类型[`java.lang.JObject`](#互操作类的特性与限制)而下面的方法`test()`仓颉不能重写

    ```java
    public interface I {}
    
    public class C {
        public static void accept(Object o) {}
        static void test(I i) { accept(i); }     //Java中的工作
    }
    ```

#### 泛型

Java 泛型在编译期间会被擦除，类型参数无论如何也不会总是出现在类文件中，因此自动生成的镜像类型是无参数化的，就像原始类型是镜像的一样。特别是，类型变量被替换为其最左边界的镜像。

也不可能手动声明参数化的镜像类型。内置类型`JArray<T>`(见[数组](#数组))是一个特殊的例外。

镜像类型不能用作常规泛型仓颉类型的类型参数[除了`Option<T>`](#泛型)。

### 数组

特殊的内置类型`java.lang.JArray<T>`用于表示 Java 数组的镜像。

类型的 Java 数组 _`T`_（ _`T`_`[]`），通常镜像为：

* `?JArray<`_`T'`_`>`，如果_`T`_是一个基元类型
* `?JArray<`_`?T'`_`>`，如果_`T`_是引用类型

其中 _`T'`_ 是的镜子 _`T`_.参考[空处理](#null-处理)为背后的理由`Option<T>`包装。

**注意：Java 数组是协变的，而仓颉泛型是不变的，类**`JArray<T>`也不例外。

### 枚举类

Java 枚举类 _`E`_ 被镜像成一个仓颉镜类 _`E'`_ 继承了镜像的`java.lang.Enum`而且两者都不是`open`也没有`sealed`本身，因此不能扩展。

类_`E'`_包含：

* 的枚举常量的镜像_`E`_，以公共静态成员的形式`let`\-类型的变量_`E'`_.
* 没有构造函数，因为无法实例化镜像类。（镜像类没有默认的构造函数。）
* 隐式定义方法的镜像`public static`_`E`_`[] values()`和`public static`_`E`_`valueOf(String name)`
* 镜像的任何`public`/`protected`原始枚举类的字段和方法，就好像它们是[普通班](#类与接口)

### 记录类

Java 记录类本质上是语法糖，和等价的常规类(参见[类和接口](#类与接口)).

Java 记录类定义有效地定义了一个常规 Java 类，它：

* 是`final`
* 不是`abstract`
* 是的直接子类`java.lang.Record`
* 包含一个或多个组件字段：`private`实例字段，每个字段都有一个匹配的访问器方法
* 可能包含`static`字段，但不包含组件字段以外的实例字段
* 包含一个规范构造函数，其参数与组件字段对应
* 可能包含其他构造函数
* 覆盖`java.lang.Object`方法`equals()`，`hashCode()`和`toString()`
* 不覆盖其他`java.lang.Object`方法

**注：方法**`hashCode()`和`toString()`在的内置镜像中重命名`java.lang.Object`。参见[`java.lang.JObject`](#互操作类的特性与限制)的详细信息。

**示例：**

```java
public record Node (int value, Node next) {}
```

```cangjie
@Java["Node"]
public foreign class Node <: Record {
    public init(value: Int32, next: ?Node)

    public func toJString(): JString
    public func hashCode32(): Int32
    public func equals(o: ?JObject): Bool

    public func value(): Int32
    public func next(): ?Node
}
```

### `null` 处理

仓颉没有空值引用的概念，因此 Java 空值类型没有等价物。如果 Java 引用类型直接镜像到各自的镜像类型，则任何`null`从 Java 方法返回给仓颉的值将导致`NoneValueException`.如果仓颉代码访问了一个这样类型的成员变量，该字段包含`null`.反之，如果 Java 调用了[互操作类](#互操作类)方法，并通过`null`作为参数之一，Java 中`NullPointerException`就会被扔出去。

最后，还必须有一个方法来通过一个`null`值从仓颉到 Java 方法或构造函数，以接受它。

实现 Java 的安全传递`null`跨语言边界和仓颉代码中的值，Java 引用类型的镜像规则扩展如下

如果字段、数组元素、方法/构造函数参数或方法返回值的原始 Java 类型是引用类型_`R`_时，该实体的自动生成的镜像具有`Option<`_`R'`_`>`，其中 _`R'`_ 是类型的镜像 _`R`_、仓颉一方`None`代表着`null`值，以及`Some(`_`r'`_`)`表示一个（非空）参考值 _`r'`_ 的类型 _`R'`_.该`cjc`编译器识别`Option<T>`作为一个[Java 兼容类型](#java-兼容类型)如果`T`是一个镜像类型，并对`T`相应地，。

例如，考虑以下 Java 接口：

```java
public interface I {
    Object f(Object[] xs);
}
```

该`xs`参数本身可以是`null`、每个元素的`xs`数组可以是`null`和`f`方法可以返回`null`因此，镜像该接口的安全方法如下：

```cangjie
@JavaMirror
public interface I {
    func f(xs: ?JArray<?JObject>): ?JObject
}
```

`Option<T>`包装也完全适用于[互操作类](#互操作类)，因为这些类型的值可以传递给 Java 或从 Java 传递。此外，建议将其应用于 Java 公开的互操作类成员函数和构造函数的参数类型，以及此类成员函数的返回值类型。

出于同样的原因，你应该使用`Option<T>`在 interop 类的代码中声明一个外部类型的局部变量时，除非你百分之百确定它不会被赋值`null`.

```cangjie
//假设M是Java镜像类型
    let m: M = M()     //如果M()成功返回，则保证
                       //返回一个新的M实例
```

总之，`Option<T>`包装可以确保代码不会被破坏，如果`null`值可以从 Java 中潜入仓颉世界，但它这样做是以牺牲性能和内存占用为代价的。这种方法的另一个缺点是[方差损失](#方差损失)而且更麻烦[类型测试和转换](#null-aware-类型测试和转换)。

#### 方差损失

一个限制是由[`Option<T>`包装](#null-处理)Java 镜像类型和互操作类的特点是，这样的包装类型在所有其他方面都遵循仓颉的语义。特别是，`Option<T>`是_通过其类型参数来固定`T`_：`Option<U>`不是的子类型`Option<T>`如果`U`是的一个子类型`T`，除非`U`和`T`都是相同的类型。对于镜像类型，这意味着依赖于返回类型协变的任何重写 Java 方法可能不会以这种方式镜像`Option<T>`包装。它的返回类型必须从超类方法传播。

**示例：**

假设一个 Java 类`Foo`是类的直接超类`Bar`：

```java
public class Foo {}

public class Bar extends Foo {}
```

和接口`C`声明一个方法`get`返回的实例`Foo`：

```java
public interface C {
    public Foo get();
}
```

的子接口`C`然后可以覆盖`get`更精确的返回类型，`Bar`：

```java
public interface D extends C {
    @Override
    public Bar get();
}
```

没有`Option<T>`包装，所有这些类型都可以镜像到：

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
    public override open func get(): Bar       //返回类型协方差的作用
}
```

但是如果`get()`可能会回来`null`，异常是不可避免的。

`Option<T>`包装使其安全，但所有重写方法的返回类型必须降低为原始方法的返回类型：

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
    //public open func get()：？Bar//错误，`Option<T>`不是T的协变
    public open func get(): ?Foo       //OK，但是返回类型降低了
}
```

可空性注释可以部分缓解这个问题，但仓颉 SDK 的当前版本不支持它们。

#### `null`\-aware 类型测试和转换

**重要提示：外部类型的可空值，使用**`Option<T>`包装，需要在类型测试和转换之前进行空值测试和取消包装，原因有两个：

1. 仓颉泛型对于其类型参数是不变的，所以_`e`_`is Option<`_`T`_`>`求值为`true`仅当表达式的类型_`e`_是`Option<`_`T`_`>`具体来说，不是一些`Option<`_`U`_`>`其中_`U`_`<:`_`T`_.

    出于同样的原因，您不能向上或向下转换`Option<T>`\-包装值：

    ```cangjie
    open class Foo {}
    class Bar <: Foo {}
       .  .  .
        let bar: Bar = Bar()
        let foo: Foo = bar                         //好的
        let bar2: Bar = (foo as Bar).getOrThrow()  //好的
    
    
        let maybeBar: ?Bar = Some(Bar())
        let maybeFoo: ?Foo = maybeBar              //错误：类型不匹配
        let maybeBar2: ?Bar = (maybeFoo as Option<Bar>).getOrThrow()
                                                   //抛出NoneValueException
    ```

    > **提示：使用**`Option`类型成员函数`.map()`和`.flatMap()`分别为上转和下转写简写：
    >
    > ```cangjie
    > //上移（从子类型到超类型）：
    >     //- Lambda返回类型是从变量类型推断的，'因为'不需要
    >     let maybeFoo: ?Foo = maybeBar.map{ bar => bar }
    > 
    >     //下移（从超类型到子类型）：
    >     //- Lambda返回类型从lambda主体推断
    >     //-与map()不同的是，flatMap()会删除过多的Option包装器
    >     let maybeBar2 = maybeFoo.flatMap{ foo => foo as Bar }
    > ```

2. 在 Java 中，`null instanceof`_`T`_求值为`false`对于任何引用类型_`T`_、在仓颉_`e`_`is Option<`_`T`_`>`求值为`true`如果_`e`_求值为`Option<`_`T`_`>.None`.

    > **提示：Java 类型比较运算符的语义**`instanceof`在仓颉可能复制如下：
    >
    > ```java
    > //Java：
    > void f(o: Object) {
    >     if (o instanceof T) { ... }
    > }
    > ```
    >
    > ```cangjie
    > //仓颉：
    > func f(o: ?JObject): Unit {
    >     if (let Some(t) <- o && t is T) { ... }
    > }
    > ```

### 循环导入依赖处理

包之间的循环依赖不仅是可能的，而且在 Java 中无处不在。例如，无所不在的类`java.lang.String`取决于类`Charset`从包`java.nio.charset`和类`Locale`从`java.util`.这两个类当然取决于类`Object`从包`java.lang`，到`String`属于！

编译分离`.class`文件和后期绑定在 Java 中有效地规避了这个问题。但是，要编译仓颉导入声明，它导入的整个包（从中）必须已经编译。因此，属于给定包的所有仓颉源文件必须在一个会话中一起编译为单个二进制文件。可以说，仓颉的最小编译单元是一个完整的包，而不是一个单独的文件。因此，在仓颉代码中，包之间的循环导入依赖是不可能的。

#### 单包模式

以上的[差值](#循环导入依赖处理)这两种语言之间的区别是，在镜像生成过程中不保留 Java 包名。实际上，镜像生成器必须始终将所有生成的镜像类型收集在一个单独的包中。必须使用选项指定所需的包名称`--package-name`.

例如，如果使用以下选项运行镜像生成器：

`--package-name java.world`

它将把所有生成的镜像类型声明放在`java.world`打包并将原始 Java 类型的完全限定名传播到`cjc`编译器作为的参数`@JavaMirror`注释：

```cangjie
package java.world

import java.lang.*

@JavaMirror["java.lang.Cloneable"]
public interface Cloneable {
}
```

#### 名称冲突

在不同包中声明的 Java 类型可能具有相同的简单名称，因为它们的全限定名是不同的。例如，有一个类`Attribute`在 JDK 包中`javax.management`和一个接口`Attribute`在`javax.naming.directory`.它们的镜像不能共存于一个仓颉包。因此，镜像生成器在[单封装模式](#单包模式)并处理所有冲突的名称。具体来说，它使用每个此类类型的完全限定名来代替其简单名称，以取代点`.`带下划线`_`：

```cangjie
// src/java/world/src/javax_management_Attribute.cj
package java.world

import java.lang.*

@JavaMirror["javax.management.Attribute"]
public open class javax_management_Attribute <: Serializable {
   .  .  .
```

```cangjie
// src/java/world/src/javax_naming_directory_Attribute.cj
package java.world

import java.lang.*

@JavaMirror["javax.naming.directory.Attribute"]
public interface javax_naming_directory_Attribute <: Cloneable & Serializable {
   .  .  .
```

#### 增量镜像

将所有 Java 镜像类型放入单个仓颉包，如`java.world`不仅导致[名称冲突](#名称冲突)，但也增加了编译时开销，通常是不方便的。因此，将大量的声明分解成若干个包是非常可取的。幸运的是，并不是所有的 Java 包都在一个单一的导入依赖循环中，所以至少有一些崩溃是可能的。

首先，你可能会注意到，在任何 Android 应用程序中都有三组包，它们之间可能没有循环依赖关系：

* 应用程序包
* Android API 包
* JDK API 包

这意味着，即使在最糟糕的情况下，所有的镜像类型也可以被分离成三个仓颉包，分别代号为"`app`","`android`"和"`java`".

此外，JDK API 从 Java 9 开始已经模块化，Java 模块之间可能不存在循环导入依赖。因此，在镜像过程中复制 JDK API 模块的结构是完全可能的。例如，仓颉包`java.base`然后，将包含从`java.base`JDK API 模块：`java.lang`及其子包，`java.io`，`java.math`、等。

最后，第三方库不应与其他应用程序组件和 API 有循环导入依赖关系。如果您的应用程序包含任何此类库，您也需要从仓颉代码中使用，则您可能希望将每个库镜像到其自己的仓颉包。

增量镜像过程实现了这种隔离。你为每个目标仓颉包运行一次镜像生成器(设置为`--package-name`选项，如往常一样)，每次指定两个附加参数：

1. 要镜像到特定目标包的 Java 包的完整列表。这些 Java 包之间可能有循环导入依赖关系，也可能导入先前镜像的包/类型。
2. 所有先前镜像的 Java 类型的完全限定名称映射的累积列表。最初，此列表是空的。

镜像生成器为属于列表（1）中出现的包的所有公共类和接口，以及它们可能具有的不在列表（2）中的任何依赖项发出镜像。然后将所有新建立的 Java →仓颉名字映射追加到列表（2）中。

##### 命令行语法

增量镜像目前只在单 jar 模式下支持，也就是说[镜像生成器命令行](#命令行语法-1)必须设置系统属性`jar.mode`到`true`并将 jar 文件的路径名作为参数传递，而不是完全限定的类型名称：

```shell
java -Djar.mode=true \
    system-properties \
    -jar ${CANGJIE_HOME}/tools/bin/java-mirror-gen.jar \
    options \
    jar-file
```

_`system-properties`_必须包括以下内容：

* `-Dpackage.mode=true`
* `-Dpackage.name=`_`target-package-name`_

    _`target-package-name`_是目标仓颉包的名称。镜像生成器会将所有镜像类型放入该包中。

    **重要提示：每次在增量模式下运行镜像生成器时，都必须指定一个新的、以前未使用的目标包名称。如果你将一些类型镜像到，比如`my.java.libs`在镜像生成器的第一次运行中使用包`-Dpackage.name=my.java.libs`并针对不同的输入再次运行它，但不改变`package.name`，这将使镜像的结果完全无效，使它们不一致。**

    > 在一定意义上，目标仓颉包是镜像的最小单位，就像你在仓颉开发时，源仓颉包是编译的最小单位：你不能单独编译属于同一个包的两个仓颉源文件。
* `-Djar.mode.packages=`_`pathname`_

    _`pathname`_必须指向包含 Java 包名列表的纯文本文件。具体来说，该文件的每一行都必须是完全限定的包名，后跟一个通配符（可选）`.*`：

    ```text
    com.example.model
    com.example.ui.*
       .  .  .
    ```

    **注意：如果通配符存在，则该条目与指定包的所有子包以及包本身匹配。这与 Java 和仓颉导入语句中通配符的语义不同。**

    生成器将为列出的包中定义的所有非匿名非私有类型及其所有依赖项发出镜像，导入映射文件中已经存在的依赖项（如果有）除外。所有这些镜像类型将被放置在一个使用`--package-name`选项（见上文）。

    此选项只能在单 jar 模式下使用。
* `-Dimports.config=`_`import-mappings-file`_

    _`import-mappings-file`_是导入映射文件的路径名，该文件是一个纯文本文件，在生成所有镜像类型时，为其累积了一组 Java 到仓颉全限定名称映射。镜像生成器在启动时读取该文件，并且不镜像已经存在映射的 Java 类型，假设它们在其先前调用（s）时已被镜像。如果镜像完成且没有错误，则镜像生成器会将它刚刚生成的所有镜像的映射添加到集合中，并将其写出到`./imports_config.txt`终止前的文件。

    **注意：如果**_`import-mappings-file`_设置为`./imports_config.txt`，该文件将被覆盖。如果您希望保留中间映射集（例如用于调试目的），则在每次增量运行镜像生成器之后创建一个副本。

#### 示例：JDK API 镜像

正如前面提到的[以上](#增量镜像),JDK API 是模块化的，因此可以看看[模块列表](https://docs.oracle.com/en/java/javase/17/docs/api/index.html)以及它们的依赖关系图，收集导出的包列表，并使用以下命令行模板运行镜像生成器：

```bash
java \
    -Dpackage.name=java.base \
    -Djar.mode.packages=./java.base.txt \
    -Dimports.config=./imports_config.txt \
    -jar ${CANGJIE_HOME}/tools/bin/java-mirror-gen.jar \
    --boot-class-path /path/to/android.jar \
    --d src/cj \
    --class-path /path/to/android.jar:/path/to/android/SDK/platform/files/directory \
    /path/to/android.jar
```

文件`./java.base.txt`应该包含从`java.base`公共使用的 JDK API 模块：

```text
java.io
java.lang
java.lang.annotation
   .  .  .
```

和文件`./imports_config.txt`应为空或不存在。

成功完成上述命令后：

* 目录`./src/cj/java/base/src`将包含具有镜像类型声明的源文件，该声明适用于在中列出的包中定义的所有公共类和接口`./java.base.txt`，和
* 该文件`./imports_config.txt`将包含所有这些 Java 类型的全限定名到它们的仓颉镜像名的映射`java.base`包，以便在后续的镜像生成器调用中使用。

> **注意：模块导出的许多类型的实现**`java.base`依赖于 JDK 内部包中定义的类和接口，如`sun.util.locale.provider.LocaleDataMetaInfo`或`jdk.internal.misc.Unsafe`.但是，镜像类型是声明的，它们不公开相应 Java 类型的任何私有成员，也不公开它们的公共方法或构造函数的实现细节。所以镜像生成器根本不会处理属于此类内部包的类文件。

现在我们可以选择一个 JDK API 模块，它只依赖于`java.base`模块，例如。`java.xml`，然后再次运行镜像生成器，仅更改以下两个选项的值：

* 设置的值`--package-name`到`java.xml`
* 设置的值`--package-list`的路径名，其中包含从`java.xml`JDK API 模块：

    ```text
    javax.xml.*
    org.w3c.dom
       .  .  .
    ```

请注意，可以将通配符`._`在包名之后，同时表示该包及其所有子包。在上面的摘录中，`javax.xml._`与包匹配`javax.xml`本身，以及`javax.xml.catalog`，`javax.xml.transform`，`javax.xml.transform.stream`、等。

```bash
java \
    -Dpackage.name=java.xml \
    -Djar.mode.packages=./java.xml.txt \
    -Dimports.config=./imports_config.txt \
    -jar ${CANGJIE_HOME}/tools/bin/java-mirror-gen.jar \
    --boot-class-path /path/to/android.jar \
    --d src/cj \
    --class-path /path/to/android.jar:/path/to/android/SDK/platform/files/directory \
    /path/to/android.jar
```

`./src/cj/java/xml/src`现在应该包含所有的镜像声明`java.xml`模块导出，而`./imports_config.txt`现在应该包含两个的映射`java.base`和`java.xml`仓颉包裹。

为其余模块重复此过程，以确保在镜像模块本身之前镜像每个模块的所有依赖项的任意顺序。

#### 使用增量镜像

您可以使用[增量镜像](#增量镜像)将需要使用的应用程序代码的任意组件与仓颉隔离开来，只要这些组件和/或 Java 代码的其余部分之间没有循环导入依赖关系。特别是，仓颉代码需要使用的每个第三方 Java 库的公共类和接口可以单独镜像到一个适当命名的仓颉包中。

要实现这一点，首先将构成应用程序的包集分解为子集，这些子集之间没有循环导入依赖关系。然后使用上述的增量镜像过程：

1. 从其他子集中选择对包没有导入依赖关系的任何子集。将其一次全部镜像到一个适当命名的包。
2. 镜像仅依赖于零个或多个先前镜像的子集的任何子集。
3. 重复上一步，直到所有要在仓颉代码中使用的 Java 类型都被镜像，每次都会选择一个新的目标仓颉包名。

### 闭包深度限制

除了众多[包之间的循环导入依赖关系](#循环导入依赖处理)，另一个特性是标准 Java API 和许多流行的 Java 库和框架固有的：巨大的导入闭包。

例如，调用镜像生成器来为空枚举类型生成镜像

```java
public enum E {}
```

使它也生成镜像`java.lang.Enum`以及标准 Java 库的所有依赖项，总共约 300 个镜像类型：

```text
AbstractInterruptibleChannel.cj
AbstractStringBuilder.cj
AccessControlContext.cj
AccessMode.cj
AccessibleObject.cj
   .  .  .
ZoneOffsetTransitionRule.cj
ZoneRules.cj
ZonedDateTime.cj
```

对于所有这些镜像类型，编译器将生成胶水代码，其中大多数是真正程序永远不会使用的。这在桌面或服务器环境中可以容忍，但在 Android 等移动平台上则不行。

要求开发人员提供一个要镜像的类型和成员的确切列表，这将是一个过分的过程。幸运的是，在计算依赖闭包期间对深度的简单限制会产生相当好的结果：生成的镜像的数量可以下降一个数量级或更多。例如，镜像上面的空枚举类型`E`深度限制为 2 时，除了该类型的镜像之外，仅产生六种镜像类型`E`本身：enum 基类`java.lang.Enum`、它实现的三个接口以及它的两个方法的返回类型：

```text
Class.cj
Comparable.cj
Constable.cj
E.cj
Enum.cj
Optional.cj
Serializable.cj
```

以下是深度限制的具体工作原理：

* 镜像类型集始终包括：

    * 原始 Java 类型，[镜像到各自的仓颉值类型](#基本类型)；
    * [类和接口类型](#类与接口)在镜像生成器命令行上显式指定；
    * `java.lang.Object`和`java.lang.String`，[分别预镜像到`JObject`和`JString`](#互操作库-api-参考)；和
    * [数组类型](#数组)的元素类型为上述列出的类型，镜像到`JArray<T>`.
* _然后，按以下方式筛选集合中包含的类型的成员：_

    * 继承的成员不会镜像为"自己的"成员，即使相应的超类型不包括在镜像类型集中。
    * 不包含在镜像类型集合中的字段的类型将被省略。
    * 如果方法的签名包含不包含在镜像类型集合中的类型，则会省略。
    * 成员类型的处理方式与顶级类型一样：除非在镜像生成器命令行上显式指定了成员类型，否则只有在此处描述的有限深度依赖关系闭合计算过程期间，如果包含在镜像类型集合中，它们才会被镜像。
* 该[命令行选项](#命令行语法-1) `--closure-depth-limit`为显式指定的类和接口类型设置深度限制。
* 如果给定类型的深度限制_`T`_为零，_没有任何类型`T`依赖项被添加到集合中_、甚至是的超类型_`T`_不添加。

    **示例：**

    ```java
    //A.java
    public class A {
        public void f(String s) {}
    }
    
    //B.java
    public class B extends A {
        public void g(String s) {}
    }
    ```

    如果镜像生成器被指示镜像类`B`深度限制为 0 时，它将仅为`B`及其方法`g(String)`，因为`JString`会自动包含在镜像类型的集合中。同时，该方法`f(String)`的，的`B`继承自`A`将不可用：

    ```cangjie
    // B.cj
       .  .  .
    @JavaMirror["B"]
    public open class B {
        public init()
    
        public open func g(s: ?JString): Unit
    }
    ```

* 如果给定类型的深度限制_`T`_ 是否有任何阳性 _`N`_，该组镜还包括以下类型，深度限制为 _`N`_`-1`：

    * 的所有（即递归收集的）超类型_`T`_；
    * 在 `T` 自身中声明的非 `private` 字段，即不是继承字段的类型；
    * `T` 的非 `private` 构造函数的参数类型；和
    * `T` 自身声明的非 `private` 方法的参数与返回类型.再次注意，继承的方法不会被扫描。

    如果一个类型已经包含在集合中，但深度限制较低，则后者将更改为_`N`_`-1`.

    对于新添加到镜像集合中的所有类型，该过程将递归地重复。

    **示例：**

    ```java
    //A.java
    public class A {
        public void f(C c) {}
    }
    
    //B.java
    public class B extends A {
        public void g(D d) { }
    }
    
    //C.java
    public class C { }
    
    //D.java
    public class D extends C {}
    ```

    若指示镜像生成器以深度限制 1 镜像类 `B`，将生成 `B`、其超类 `A`，以及 `B.g(D)` 方法参数的类型 `D`。但是，`A`和`D`将被镜像，深度限制设置为 0，因此类`C`，因此，方法`A.f(C)`不会被镜像：

    ```cangjie
    // A.cj
       .  .  .
    @JavaMirror["A"]
    public open class A {
        public init()
    }
    
    // B.cj
       .  .  .
    @JavaMirror["B"]
    public open class B <: A {
        public init()
    
        public open func g(d: ?D): Unit
    }
    
    //D.cj
       .  .  .
    @JavaMirror["D"]
    public open class D {
        public init()
    }
    ```

    最后，将深度限制设置为 2 将使镜像生成器包括类的镜像`C`和方法`A.f(C)`在其输出中。

## Java 镜像生成器参考

### 前提条件

Java 镜像生成器需要 JDK 17。若尚未安装或未加入可执行搜索 `PATH`，请先安装并配置后再使用。

还需掌握待镜像类全部依赖所在的 jar 与目录的本地路径，包括 Android 标准库 jar 以及应用启动时类路径上的 jar。

### 命令行语法

Java 镜像生成器有两种运行方式：

`java [`_`system-properties`_`] \`
`-jar ${CANGJIE_HOME}/tools/bin/java-mirror-gen.jar \`
`[`_`options`_`]`_`type-names`__（默认模式）_

为一个或多个 Java 类和/或接口及其所有依赖项生成镜像，或者

`java -Djar.mode=true [`_`system-properties`_`] \`
`-jar ${CANGJIE_HOME}/tools/bin/java-mirror-gen.jar \`
`[`_`options`_`]`_`jar-file`__（单 jar 模式）_

来生成所有类型的镜像`.class`文件，其中给定的_`jar-file`_包含和它们的所有依赖项位于提供的类路径上的其他地方（如果有）。

其中

* _`system-properties`_是镜像生成器识别的某些 Java 系统属性，使用`-D`的选项`java`发射器。
* _`options`_是[命令行选项](#命令行选项)的镜像生成器。
* _`type-names`_是需要镜像的 Java 类和接口的完全限定名(即，而不是它们的路径名`.class`文件)。
* _`jar-file`_是单个 jar 文件的路径名。

**注：(**[增量镜像](#增量镜像)和/或[闭合深度限制](#闭包深度限制)可以在每次调用镜像生成器期间限制镜像类型和/或其成员的集合。

### 命令行选项

* `--boot-class-path`_`pathname`_（必填）

    _`pathname`_必须指向`android.jar`Android SDK 中的文件，用于构建应用程序的 Java 部分。此选项必须始终存在并指向现有文件。
* `-d`_`directory`_

    _`directory`_是镜像生成器应将其包含生成的镜像类型声明的输出源代码文件放置在符合 CJPM 要求的子目录层次结构中的目录的路径名。如果未指定此选项，则假定当前目录。
* `-cp`_`path`_，`--class-path`_`path`_（必填）

    _`path`_是目录、jar 文件和 zip 文件的路径名列表，以分号分隔`;`在 Windows 和冒号上`:`在所有其他平台上。镜像生成器在查找命令行中指定的 Java 类型的类文件(_`type-names`_)以及它们的依赖关系。_`path`_必须以的路径名开头`android.jar`文件。
* `-h`，`-?`，`--help`

    打印一条帮助消息，其中包含命令行语法以及所有选项和退出的简要说明。

### 系统属性

* `-Dpackage.mode=true`（必填）

    在当前版本中必须始终指定。
* `-Dpackage.name=`_`name`_（必填）

    _`name`_是将所有生成的镜像类型放入的仓颉包的名称。[单包模式](#单包模式)的详细信息。
* `-Dgen.closure.depth=`_`number`_

    _`number`_是一个非负十进制整数，在确定将被镜像的类型及其成员集时，限制依赖图扫描的深度。

    请参见[闭包深度限制](#闭包深度限制)的详细信息。
* `-Djar.mode=true`

    单 jar 操作模式(参见[命令行语法](#命令行语法-1)以上)。
* `-Djar.mode.packages=`_`pathname`_

    _`pathname`_是包含包名称列表的纯文本文件的路径名。只有属于列出的包及其依赖项的类文件才会被镜像。需要使用单 jar 模式。[命令行语法](#命令行语法)在[增量镜像](#增量镜像)部分，以了解详细信息。
* `-Dimports.config=`_`pathname`_

    _`pathname`_是包含在先前镜像生成器运行期间累积的镜像类型映射的纯文本文件的路径名。需要单 jar 模式和`-Djar.mode.packages`，参见[命令行语法](#命令行语法)在[增量镜像](#增量镜像)部分，以了解详细信息。

### 示例

```shell
java -Dpackage.mode=true -Dpackage.name=com.example \
     -jar ${CANGJIE_HOME}/tools/bin/java-mirror-gen.jar \
    --boot-class-path ${ANDROID_SDK}/platforms/android-35/android.jar \
    --class-path ${ANDROID_SDK}/platforms/android-35/android.jar:App.jar \
    -d ./mirrors \
    com.example.subpkg1.A com.example.subpkg2.B
```

```shell
java -Djar.mode=true -Dpackage.mode=true -Dpackage.name=com.example \
     -jar ${CANGJIE_HOME}/tools/bin/java-mirror-gen.jar \
    --boot-class-path ${ANDROID_SDK}/platforms/android-35/android.jar \
    --class-path ${ANDROID_SDK}/platforms/android-35/android.jar:./Lib.jar \
    -d ./mirrors \
    App.jar
```

有关更复杂的示例，请参阅[示例：JDK API 镜像](#示例jdk-api-镜像)。

## 互操作库 API 参考

Android 互操作库包含两个基本 Java 类的镜像类型的增强版本，`java.lang.Object`和`java.lang.String`以及表示 Java 数组的泛型镜像类型。

要启用非限定名称的使用，这些镜像类型被分别调用`JObject`，`JString`，和`JArray<T>`以避免与仓颉类型的名称冲突`std.core`.

它们还重新命名了一些方法，并添加了一些新方法以增强互操作性。

### `java.lang.JObject`

`java.lang.JObject`是 Java 镜像类和互操作类的层次结构的根。它本身就是一面镜子`java.lang.Object`类，但删除了一些不支持的方法，并重命名和添加了一些方法，以更好地与仓颉标准库对齐。

**注意：方法从**`JObject`在任何其他镜像类中也是不可用的。那些是`clone()`，`finalize()`，和`getClass`.

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

实例成员函数`equals`和所有`wait/notify`函数是相应 Java 方法的镜像。

```cangjie
public func hashCode(): Int64
```

调用原始的 Java 方法`hashCode`并强制转换返回的 32 位`int`值到`Int64`.为了更好地满足仓颉开发者的期望而推出的。

```cangjie
@ForeignName["hashCode"]
public open func hashCode32(): Int32
```

Java 的原始方法`hashCode`，更名为`hashCode32`以避免名称冲突。

```cangjie
public func toString(): String
```

调用原始的 Java 方法`toString`并将其结果转化为仓颉`String`.在极不可能收到的情况下`null`从底层 Java 方法中，抛出异常。

为了更好地满足仓颉开发商的期望而推出的。

**注意：此函数返回一个仓颉**`String`，打破了只为镜像类型和互操作类的公共成员函数和构造函数的参数和返回值使用 Java 兼容类型的要求。这只是可能的，因为`cjc`编译器对这个成员函数有专门的支持。

```cangjie
@ForeignName["toString"]
public open func toJString(): JString
```

Java 的原始方法`toString`，更名为`toJString`以避免名称冲突。

Java 的一个实现`toString`是很不可能回来的`null`，因此返回类型为`JString`，不`?JString`.

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

有效地转换给定的仓颉`String`到 Java 字符串(`JString`).

**注意：这个构造函数接受一个仓颉类型的参数**`String`，打破了对镜像类型和互操作类的非私有成员函数和构造函数的参数和返回值仅使用 Java 兼容类型的要求。这只是可能的，因为`cjc`编译器有专门的支持`JString`.

成员继承自[`JObject`](#互操作类的特性与限制)：`equals`，`hashCode`，`hashCode32`，`toString`，`toJString`，`wait/notify`方法。

### `java.lang.JArray<T>`

`JArray<T>`是一个特殊的内置泛型镜像类型，它镜像所有 Java 数组类型。`T`必须是映射到基本 Java 类型的值类型，例如`Int32`或`Bool`、镜像类型或互操作类。

**限制：**

截至当前版本：

* 不支持具有可空元素的 Java 数组。换句话说，如果`T`是镜像类型或互操作类，类型`JArray<T>`支持，但类型`JArray<?T>`不是。
* Java 数组类型的变量和参数不能标记为可空`Option`enum.也就是说，即使`JArray<T>`是有效类型，`?JArray<T>`不被承认是这样的。

Java 数组的 API 与仓颉相比有一定的局限性`Array<T>`struct 类型，除了构造之外，唯一的操作是长度查询、元素访问和的继承方法`java.lang.Object`.

```cangjie
public init(length: Int32)
```

构造一个给定的新的 Java 数组`length`.

```cangjie
public prop length: Int32
```

数组中元素的数量。

```cangjie
public operator func [](index: Int32): T
public operator func [](index: Int32, value!: T): Unit
```

元素访问运算符`[]`.

成员继承自[`JObject`](#互操作类的特性与限制)：`equals`，`hashCode`，`hashCode32`，`toString`，`toJString`，`wait/notify`方法。

## 执行

### Java 类加载器

所有镜像类型和互操作类的 Java 对应类必须由同一个类加载器加载。

### 初始化

所有仓颉全局变量都会被初始化，所有仓颉类型的静态初始化器都会在控制第一次到达仓颉代码时被调用，也就是说，当任何[互操作类](#互操作类)是第一次在 Java 代码中使用。

如果所有的初始化代码使用了除已触发初始化的类型及其超类型之外的任何镜像类型或互操作类，则相应的 Java 类型也会被初始化，并对其超类型产生级联效应。

换句话说，在 interop 场景中，当控制第一次到达仓颉代码时，相当数量的 Java 类和接口可能会同时被加载和初始化。如果在应用程序启动时发生这种情况，那么它将花费更长的时间，并且应用程序的初始内存占用将比完全用 Java 或某些其他 JVM 语言编写相同的应用程序逻辑更高。Java 类和接口初始化的相对顺序也可能不同。所有这些都是预期的行为。

> Java 类和接口在第一次使用时初始化，可以是：类实例化`static`方法调用，赋值给`static`字段，检索一个`static`不是常量变量的字段、子类初始化、实现类初始化（仅当接口声明了默认方法时）或某些反射方法的调用。

### 终结

#### Java 终结器

互操作类可能不实现`finalize()`的方法`java.lang.Object`.该类的内置镜像[`java.lang.JObject`](#互操作类的特性与限制)，甚至没有声明该方法。

> 试图在 interop 类中定义 Java 终结器：
>
> ```java
> @JavaImpl
> public class C {
>        .  .  .
>     public func finalize(): Unit {
>            .  .  .
>     }
> 
> }
> ```
>
> 实际上会导致名称冲突和编译时错误，因为启用互操作的代码出于自己的目的使用 Java 终结器。

#### 仓颉终结者

镜像类声明不能包含仓颉终结器(`~init()`).

它是否一个待定[互操作类](#互操作类)可以包含终结器。

### 异常

Java 和仓颉都具有异常-中断程序正常控制流的事件，通常是为了发出信号，表明发生了非致命的执行错误，需要处理。

在 CJMP 支持的双向互操作场景中，控制可以在嵌套调用链中多次在用不同语言编写的方法/函数之间传递。因此，当在 Java 或仓颉代码中抛出异常时，线程堆栈上可能会穿插着许多 Java 和仓颉框架。这反过来意味着堆栈展开过程可能需要跨越语言边界。以下是它的工作原理：

如果仓颉代码中方法的 Java 构造函数的调用由于未捕获的 Java 异常而突然完成，则会立即抛出具有以下特征的仓颉异常：

* 如果 Java 异常是一个`Error`(即其类型为`java.lang.Error`或其子类)，仓颉异常也是一个`Error`，否则它是一个`Exception`.
* 的价值`message`属性包含由`getMessage()`Java 异常的方法。
* 由返回的数组的元素`getStackTrace()`都是待定的。

如果在堆栈展开过程再次到达 Java 帧之前，新的异常没有被捕获，那么原始的 Java 异常将被重新抛出，整个过程将被重复。（如果线程是仓颉创建的，可能没有这样的 Java 框架）`spawn`，在这种情况下，待定。)

如果在仓颉代码中的某个地方抛出异常，也就是说，不是由于前一段描述的从仓颉到 Java 的跨语言调用突然完成的结果，而堆栈的展开过程又到达了 Java 帧，则 Java 异常(`java.lang.Exception`)具有以下特征的问题将被抛出：

* 它的弦`getMessage()`方法返回的值包含`message`仓颉异常的属性。
* 由返回的数组的元素`getStackTrace()`待定。

该 Java 异常除了与后者关联的消息之外，不保留任何关于原始仓颉异常的信息，并且会被进一步处理，就像最初的 Java 异常一样（详见上文）。

没有办法`throw`仓颉代码中的 Java 异常，反之亦然。

### 内存管理

Java 和仓颉对象分别驻留在不同的堆中。各自的语言运行库管理这两个堆中的每一个。如果对一种语言堆中的对象的引用仍然存在于另一种语言的变量和数据结构中，则互操作库和桥接代码确保它们不会被垃圾回收。

**重要提示：在存在跨语言引用的情况下，确保两个堆的一致性的机制有两个重要限制，在使用互操作工具时，必须始终理解和记住这些限制：**

1. Android 虚拟机对可能同时存在于虚拟机外部的 Java 堆对象引用的数量进行了硬限制，特别是在变量和数据结构中。因此，建议尽量避免在全局变量和长寿命数据结构中存储这样的引用。注意：这包括镜像类型和互操作类的实例。

    此外，当仓颉一方不再需要这些引用时，释放这些引用的效率和时机完全取决于仓颉垃圾回收器。即使从应用程序开发人员的角度来看，引用是短暂的，但这并不意味着当持有它的最后一个变量被赋予新值时，它就会立即被释放。在循环中遍历仓颉代码中的大型 Java 数组或集合可能会创建数千个这样的引用。这可能会导致应用程序在调用仓颉垃圾回收器之前就达到了 Android 虚拟机的上述硬限制。然后，应用程序将异常终止，就像它已经用完内存一样。
2. 由于 Java 和仓颉垃圾回收器各自在各自的托管环境中单独运行，因此跨语言循环引用可能导致内存泄漏。创建这样的引用必须要么完全避免，要么伴随着在构成循环的对象从应用程序代码的 Java 和仓颉部分变得不可达之前打破这样的循环的逻辑。

### 线程

仓颉造的一条线`spawn`当它第一次跨越两种语言的边界时，会自动作为守护进程线程连接到 JVM：实例化一个镜像/互操作类，调用其`static`在仓颉等中没有（重新）定义的方法。
