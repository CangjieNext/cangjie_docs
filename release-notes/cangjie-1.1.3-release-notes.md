# Cangjie 1.1.3 Release Notes

## 版本介绍

`Cangjie 1.1.3` 为 `STS 1.1` 第二个发布版本，`STS 1.1` 维护周期6个月。

**相比 1.1.0 版本**，本版本无新增特性，无变更特性，修复了若干问题；各模块修复问题详见本文档各章节介绍。

## 编译器

### 修复问题

- [issue#3118](https://gitcode.com/Cangjie/UsersForum/issues/3118) 优化宏展开生成错误注解调用时的报错信息。
- [issue#783](https://gitcode.com/Cangjie/cangjie_compiler/issues/783) 修复 `struct` 和 `class` 元数据缺少 `reflectVersion1` 标记导致运行时反射无法正确识别类型元数据的问题；`reflectVersion1` 属性现同步写入 struct/class/box_class 的 `GenerateAttrsMetadata`。
- [issue#3116](https://gitcode.com/Cangjie/UsersForum/issues/3116) 修复管道运算符结合 trailing lambda 调用重载函数时，类型推断触发 ICE（SIGSEGV）的问题。受影响场景：`f |> { x => overloaded(x) }` 且无类型标注时必现崩溃，根因为 `TryEnforceCandidate` 中 PSet checkpoint 深度不一致。
- [issue#2807](https://gitcode.com/Cangjie/UsersForum/issues/2807) 修复注解嵌套宏场景下宏展开失败的问题，覆盖两类场景：① 注解嵌套宏展开后生成子宏；② 宏展开结果本身包含注解嵌套宏。
- [issue#794](https://gitcode.com/Cangjie/cangjie_compiler/issues/794)：修复 **macOS**  链接 `libcangjie-std-ast.a` 时动态/静态混用导致 AST 相关接口出错的问题。
- [issue#470](https://gitcode.com/Cangjie/cangjie_compiler/issues/470)：修复 **Windows** 场景 Driver 调用 `posix_spawn` 失败时缺少错误消息的问题，修正 `FORMAT_MESSAGE_ALLOCATE_BUFFER` 内存分配及 `LocalFree` 释放逻辑。
- [issue#465](https://gitcode.com/Cangjie/cangjie_runtime/issues/465) 修复读写 `global struct` 成员时写/读屏障缺失，在 aarch64 上导致随机崩溃或数据竞争的问题。
- [issue#820](https://gitcode.com/Cangjie/cangjie_compiler/issues/820) 修复虚函数去虚化时，泛型实例化后多个函数签名相同、过滤逻辑缺失导致选错目标方法、运行时调用到错误函数的问题。
- [issue#879](https://gitcode.com/Cangjie/cangjie_compiler/issues/879) 修复内联优化后去虚化阶段 src class 类型计算有误的问题：子类虚函数出现在多个父类虚表时，需通过偏移量比对选取正确父类，原实现过早断言唯一结果导致行为错误。
- [issue#776](https://gitcode.com/Cangjie/cangjie_compiler/issues/776)  修复 VTable 生成中泛型参数类型映射错误的问题（issue #776），泛型继承场景下虚表条目类型不正确，改用 `ReplaceRawGenericArgType` 进行泛型参数类型替换。
- [issue#841](https://gitcode.com/Cangjie/cangjie_compiler/issues/841) 修复 override wrapper 返回 `CPointer<T>` 时生成非法 LLVM IR、触发 verifier ICE 的问题。
- [issue#851](https://gitcode.com/Cangjie/cangjie_compiler/issues/851)：修复 **Windows**  下同时依赖 AST 库并启用静态链接时 `libgcc_s` 链接方式无效的问题。

## 运行时

### 修复问题

- [issue#513](https://gitcode.com/Cangjie/cangjie_runtime/issues/513) 修复涉及泛型实例类型多次接口查询的场景报错的问题。
- [issue#592](https://gitcode.com/Cangjie/cangjie_runtime/issues/592) 修复 `IntervalEndAsync` 偶发崩溃报错问题。
- [issue#465](https://gitcode.com/Cangjie/cangjie_runtime/issues/465) 修复并发读取/修改 `global struct` 偶发随机崩溃问题。
- [issue#590](https://gitcode.com/Cangjie/cangjie_runtime/issues/590) 修复 `SchdfdInit ` 并发随机问题。

## 标准库

### 修复问题

- [issue#621](https://gitcode.com/Cangjie/cangjie_runtime/issues/621)：修复库文档中代码块代码风格不统一问题。
- [issue#579](https://gitcode.com/Cangjie/cangjie_runtime/issues/579)：优化标准库构建。
- [issue#603](https://gitcode.com/Cangjie/cangjie_runtime/issues/603)：修复 `std.time` 和 `std.unicode` 边界行为问题。
- [issue#577](https://gitcode.com/Cangjie/cangjie_runtime/issues/577)：修复 `CJ_RawAddressDestroy` 悬空指针问题。
- [issue#574](https://gitcode.com/Cangjie/cangjie_runtime/issues/574)：修复 `matchResult` 没有初始值问题。
- [issue#578](https://gitcode.com/Cangjie/cangjie_runtime/issues/578)：移除 `std.unittest` 代码中已不存在的接口，并补充函数返回值类型。
- [issue#550](https://gitcode.com/Cangjie/cangjie_runtime/issues/550)：修复 HashSet 遍历方法访问无效条目问题。
- [issue#571](https://gitcode.com/Cangjie/cangjie_runtime/issues/571)：修复 Decimal `Float32` 构造函数缺少 scale 溢出检查问题。
- [issue#569](https://gitcode.com/Cangjie/cangjie_runtime/issues/569)：修复抽象 UDS 路径长度校验问题。
- [issue#567](https://gitcode.com/Cangjie/cangjie_runtime/issues/567)：统一 `Windows` 下的 `addrinfo` 定义与实现。
- [issue#525](https://gitcode.com/Cangjie/cangjie_runtime/issues/525)：修复 `std.net` 包中 `isMulticast` 逻辑错误等问题。
- [issue#545](https://gitcode.com/Cangjie/cangjie_runtime/issues/545)：修复 `std.math` 相关问题。
- [issue#521](https://gitcode.com/Cangjie/cangjie_runtime/issues/521)/[issue#527](https://gitcode.com/Cangjie/cangjie_runtime/issues/527)：修复  `std.core` 相关问题。
- [issue#541](https://gitcode.com/Cangjie/cangjie_runtime/issues/541)：修复 `std.binary` 的问题。
- [issue#548](https://gitcode.com/Cangjie/cangjie_runtime/issues/548)：修复 `std.process` 中的安全问题。
- [issue#522](https://gitcode.com/Cangjie/cangjie_runtime/issues/522)：修复 `std.collection` 中的安全问题。
- [issue#530](https://gitcode.com/Cangjie/cangjie_runtime/issues/530)：修复 `std.fs`  `walk`函数资源泄漏等问题。
- [issue#524](https://gitcode.com/Cangjie/cangjie_runtime/issues/524)：修复 `std.sync`、`std.crypto` 中的安全问题。
- [issue#547](https://gitcode.com/Cangjie/cangjie_runtime/issues/547)：修复 `std.interop` 中的安全问题。
- [issue#561](https://gitcode.com/Cangjie/cangjie_runtime/issues/561)：修复 `std.regex` 中的安全问题。
- [issue#559](https://gitcode.com/Cangjie/cangjie_runtime/issues/559)：修复 `std.unicode` 中的安全问题。

## 工具链

### IDE插件

#### 修复问题

- [issue#398](https://gitcode.com/Cangjie/cangjie_tools/issues/398) 修复复杂中文路径场景下无法正常提供语言服务的问题。

### cjpm

#### 修复问题

- [issue#465](https://gitcode.com/Cangjie/cangjie_tools/issues/465) 修复开启流水并行特性后的增量编译问题。

### cjdb

#### 修复问题

- [issue#111](https://gitcode.com/Cangjie/llvm-project/issues/111) 修复 `MacOS` 26 系统上 `cffi` 单步调试失败问题。
- [issue#121](https://gitcode.com/Cangjie/llvm-project/issues/121) 修复调试工具中整数越界等问题。

### cjfmt

#### 修复问题

- [issue#421](https://gitcode.com/Cangjie/cangjie_tools/issues/421) 修复数据越界问题。

### cjlint

#### 修复问题

- [issue#417](https://gitcode.com/Cangjie/cangjie_tools/issues/417) 修复 `system` 接口拼接命令字符串问题。

## 文档变更说明

### 开发指南

“类型转换”章节新增“类型模式与子类型转换”小节。


