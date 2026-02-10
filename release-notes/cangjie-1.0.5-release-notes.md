# Cangjie 1.0.5 Release Notes

## 版本介绍

该版本版本号 `1.0.5`, 本版本**相对于 1.0.4 版本**新增 `--no-prelude` 支持 `std.core` 独立构建，修复 `lambda` 内对 `let` 变量赋值的问题。该版本包含使用仓颉开发应用的必备能力，包括编译器、运行时、标准库和工具链，欢迎各位开发者使用。如有任何问题，欢迎在仓颉社区[提交issue](https://gitcode.com/org/Cangjie/issues)。

请注意，本版本相对于前一个版本**切换了Windows平台构建工具**，详情请见[不兼容变更说明](#不兼容变更说明)章节。

## 编译器

### 新增特性

`cjc` 支持 `--no-prelude` 选项（仅用于构建 std.core 包使用）。

### 修复问题

【[cangjie_compiler/issues/132](https://gitcode.com/Cangjie/cangjie_compiler/issues/132)】修复 `Option<T>` 作为返回值时，当 `T` 为 `Array`、`ArrayList` 时，多层 API 调用时返回值不正确的问题。

## 标准库

### 修复问题

【[cangjie_runtime/issues/227](https://gitcode.com/Cangjie/cangjie_runtime/issues/227)】RelWithDebInfo 下交叉编译 Windows 报错：error: unsupported option '-fdebug-types-section' for target 'x86\_64-w64-windows-gnu'。

## 工具链

### cjdb

#### 修复问题

【[llvm-project/issues/30](https://gitcode.com/Cangjie/llvm-project/issues/30)】CFFI 在单步调试时无法由单步从仓颉侧运行至 C 侧。 

## 遗留问题

### 在 lambda 表达式体内对 let 静态变量赋值，编译通过，未报错

【问题现象】在 `lambda` 表达式体内对 `let` 静态变量赋值可能导致重复赋值（因为 `lambda` 可能被多次执行），但是 cjc 编译通过，并未报错，这和设计预期不符。详情请参见【[cangjie_compiler/issues/105](https://gitcode.com/Cangjie/cangjie_compiler/issues/105)】。

【解决措施】避免在 `lambda` 中对静态变量赋值。

### 使用 struct 修改属性，cjlint 报 G.VAR.01 告警

【问题现象】使用`struct` 修改属性，cjlint 报 G.VAR.01 告警，和实际预期不符。详情请参见【[UsersForum/issues/2576](https://gitcode.com/Cangjie/UsersForum/issues/2576)】。

【解决措施】少量场景存在误报，暂时可以手动屏蔽。预计下一个版本修复该问题。

## 不兼容变更说明

- `1.0.5` Windows 版本由原来基于 GCC 构建切换为基于 LLVM-MinGW 构建，因此，`1.0.5` 版本 Windows 平台的仓颉 SDK 与之前版本的仓颉 SDK 不保证 ABI 兼容，即 `1.0.5` 版本 Windows 平台仓颉 SDK 与之前版本 Windows 平台的运行时标准库无法混合使用。
- 仓颉 SDK 中有部分目录名称变更，若升级仓颉 SDK 至 `1.0.5` 版本，则需要同步升级配套的仓颉开发工具，例如仓颉 IDE 插件。

## 文档变更说明

开发指南：新增 cjc 编译选项  `--no-prelude` 的介绍。

