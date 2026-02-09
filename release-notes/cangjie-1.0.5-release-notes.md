# Cangjie 1.0.5 Release Notes

## 版本介绍

该版本版本号 `1.0.5`, 本版本**相对于 1.0.4 版本**新增 `--no-prelude` 支持std.core独立构建，修复 `lambda` 内对 `let` 变量赋值的问题。

* 请注意，本版本相对于前一个版本**切换了Windows平台构建工具**，详情请见 [不兼容变更说明](#不兼容变更说明) 章节。

## 编译器

### 新增特性

- cjc 支持 `--no-prelude` 选项（仅用于构建 std.core 包使用）

### 修复问题

- 【[cangjie_compiler/issues/30](https://gitcode.com/Cangjie/cangjie_compiler/issues/132)】修复 Option\<T\> 作为返回值时，当 T 为 Array，ArrayList 时，多层 API 调用时返回值不对的问题。

## 标准库

### 修复问题

- 【[issue227](https://gitcode.com/Cangjie/cangjie_runtime/issues/227)】RelWithDebInfo 下交叉编译 windows 报错: error: unsupported option '-fdebug-types-section' for target 'x86\_64-w64-windows-gnu'。

## 遗留问题

|issue|问题描述|影响及规避方案|
|---|---|--|
| [cangjie_compiler/issues/105](https://gitcode.com/Cangjie/cangjie_compiler/issues/105) | 在 `lambda` 表达式体内对 `let` 静态变量赋值，编译通过，未报错 | 在 `lambda` 表达式中对 `let` 静态变量赋值可能导致重复赋值（因为 `lambda` 可能被多次执行），从而违背设计预期。规避方案：避免在 `lambda` 中对静态变量赋值。 |
=======
## 工具链

### cjdb

#### 修复问题

- 【[llvm-project/issues/30](https://gitcode.com/Cangjie/llvm-project/issues/30)】CFFI 在单步调试时无法由单步从仓颉侧运行至 C 侧。

|issue|问题描述|影响及规避方案|
|---|---|--|
| [cangjie_compiler/issues/105](https://gitcode.com/Cangjie/cangjie_compiler/issues/105) | 在 `lambda` 表达式体内对 `let` 静态变量赋值，编译通过，未报错 | 在 `lambda` 表达式中对 `let` 静态变量赋值可能导致重复赋值（因为 `lambda` 可能被多次执行），从而违背设计预期。规避方案：避免在 `lambda` 中对静态变量赋值。 |  
| [UsersForum/issues/2576](https://gitcode.com/Cangjie/UsersForum/issues/2576) | 使用struct修改属性，cjlint不应该报G.VAR.01告警 | 少量场景存在误报，可以通过手动屏蔽暂时规避，下个版本修复 |  

## 不兼容变更说明

- Windows 版本仓颉 SDK 现基于 LLVM-MinGW 构建，使用本版本编译的 Windows 平台仓颉二进制与先前版本编译的仓颉二进制不再有 ABI 兼容保证：
    - 现版本/先前版本的 Windows 平台仓颉二进制无法和先前版本/先版本的 Windows 平台运行时标准库混合使用。
- 仓颉 SDK 中有部分目录名称变更，若升级仓颉 SDK 至 1.0.5 版本则需要同步升级其他配套仓颉开发工具，例如仓颉 IDE 插件。

## 文档变更说明

    无

