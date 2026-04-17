# Cangjie 1.1.0 Release Notes

## 版本介绍

`Cangjie 1.1.0` 为 `STS 1.1` 第一个发布版本，`STS 1.1` 维护周期6个月。

**相比 1.0.5 版本**，本版本新增 `Android/iOS` 跨平台运行，中心仓等重要特性； 修复了若干问题；各模块功能详见本文档各章节介绍。

## 编程语言

### 新增特性

- 新增组织名语法。
- 新增 `common/specific` 语法，用于支持跨平台抽象，**注意该特性为实验特性。**

## 编译器

### 新增特性

- 新增支持 `--dump-xxx` 选项供开发者调试分析编译器中间行为。
- 新增交叉编译至 `-linux-x64-ohos` 场景 `LTO`（链接时优化）支持。
- 条件编译新增 `env` 内置编译条件变量，用于消除目标平台之间的歧义。
- 新增支持 `iOS`（arm64、arm64 模拟器、x86_64 模拟器）交叉编译。
- 新增支持 `Android`（aarch64）交叉编译，最低支持 `API 26`（`Android 8`）。
- `cjc` 支持 `--output-type=obj` 选项支持生成目标文件，该选项为实验性选项。
- `cjc` 支持 `--compile-target` 选项支持指定生成目标文件的类型，该选项为实验性选项。
- `cjc` 支持 `--output-type=chir`/`--common-part-cjo` 选项，配套 `common/specific` 实现。

### 变更特性

|变更前|变更后|适配举例|
|---|---|---|
| `-g` 选项启用时， `--apc` 会默认启用 | `-g` 选项启用时，不默认启用 `--apc` | 在指定 `-g` 时，显式指定 `--apc` 选项 |
| 更换版本后，`cjo` 格式一致，可以增量编译 | 更换版本后，`cjo` 格式不一致，增量编译失败 | 更换版本后，执行 clean 后重编译 |

### 修复问题

- [issues-388](https://gitcode.com/Cangjie/cangjie_tools/issues/388) 修复打开特定中文路径的 `.cj` 文件崩溃问题。
- [issue-36](https://gitcode.com/Cangjie/cangjie_compiler/issues/36) 修复多包 extend 场景，虚函数调用会导致运行时崩溃和调试时表达式求值失败问题。
- [issue-154](https://gitcode.com/Cangjie/cangjie_compiler/issues/154) 修复调试时可能会跳到 0 行的问题。
- [issue-639](https://gitcode.com/Cangjie/cangjie_compiler/issues/639) 修复编译器添加的 `vardecl` 不存在包名时，导致编译器 mangle crash 问题。
- [issue-697](https://gitcode.com/Cangjie/cangjie_compiler/issues/697) 修复运行时读取堆上数据有低概率崩溃的问题。

## 运行时

### 新增特性

- 仓颉运行时新增支持在 `iOS`（arm64、arm64 模拟器、x86_64 模拟器）上运行。
- 仓颉运行时新增支持在 `Android`（aarch64）上运行。 `Android` 版本最低要求 `API 26`（Android 8.0）。
- 仓颉运行时新增支持在 HarmonyOS（arm32）上运行。
- 提供 `exclusiveScope` 依赖的绑定 `OS` 线程和仓颉线程栈与 `OS` 线程栈切换的能力。
- 仓颉运行时新增 `iOS` 平台上支持仓颉未捕获异常处理。

### 修复问题

* [issues-2725](https://gitcode.com/Cangjie/UsersForum/issues/2725) 反射获取 `superInterfaces` 不符合预期结果问题修复。

## 标准库

### 新增特性

- `std.ast` 包支持解析包含组织名语法的仓颉代码。
- `std.collection` 包提供非迭代器版本容器操作。
- `std.core` 包增加全局 `public` 函数 `exclusiveScope` 解决仓颉线程调用 `Java` 互操作问题。
- `std.core` 包新增支持对函数的 `refEq` 重载。
- `std.core` 包新增 `Error` 支持注册处理函数。
- `std.core` 包新增异常支持 `causedBy` 。
- `std.core` 包支持 `Array<Byte>` 无拷贝转 `String` 。
- `std.core` 包新增获取全量仓颉线程的调用栈和线程状态接口
- `std.reflect` 包支持反射 `struct`、`func`、`lambda`、`tuple` 。
- `std.runtime` 包支持 `signal` 监听类接口。
- 支持 `ios-x86_64` 模拟器。
- 支持 `ohos-arm32` 。

### 变更特性

|变更前|变更后|适配举例|
|---|---|---|
| 依赖的`PCRE2` 版本为`10.44`  |  依赖的`PCRE2` 版本升级到`10.46`  |  NA |
|`LTS 1.0.0` 之后的 SDK 版本间，编译产物二进制兼容|异常链特性给 `Exception` 新增 `private` 成员变量，反射特性给 `TypeInfo` 新增 `private` 成员变量，导致出现二进制不兼容。|使用本版本（及更新版本）SDK 对项目代码及其依赖包代码执行全量重编译。 |

### 修复问题

- 对 `std.fs` 的异常信息进行了优化，确保异常包含足够的定位信息。
- 对 `Array` 完善异常信息导致的性能和 codesize 劣化进行修复。
- 在资料中补充 `API` 示例代码，提升资料易读性。

## 工具链

### IDE插件

#### 新增特性

- 新增支持中心仓特性。
- 新增支持组织名语法的语言服务。
- 新增支持 `common/specific` 新语法的语言服务。
- 提供 debug 启动按钮，支持仓颉项目一键启动调试。
- 优化了语言服务增量代码诊断性能。

### cjpm

#### 新增特性

- 新增中心仓特性，包括制品发布、下载、索引机制、依赖解析等。
- 新增工程级` lto-combine` 特性。
- 支持组织名配置。
- 新增源码依赖增量扫描特性。
- 新增流水线并行编译优化特性。
- `run `命令支持通过 `--` 标记入参。
- 支持配置构建脚本产物路径。
- 新增 `cjc` 并行度透传控制特性。
- 新增平台隔离 ffi.c 配置项。
- 新增跨平台项目构建支持。

#### 变更特性

- 通过 `version` 标注中心仓依赖项，与现有 `path/git` 属性不能同时使用，影响如下字段：
  - dependencies
  - test-dependencies
  - script-dependencies
  - replace
- `cjc` 启发式并行度配置从默认开启变为需要手动开启。
- 由于 `cjo` 格式变化，切换新版本 `cjpm` 后，存量工程增量编译会出现产物不兼容，需要执行 clean 之后重编译。
- 修复 `toml` 解析复合字段存在同名的空和非空版本时不会冲突的问题，需要删除冗余配置。

|变更前|变更后|适配举例|
|---|---|---|
| 依赖项中同时配置 `path/version` 和 `git/version` 时，<br>`version` 字段不校验，因此不出现配置错误 | 因中心仓功能引入，校验 `version` 字段，<br>与 `path/git` 冲突，导致配置错误 | 删除冗余的 `version` 字段 |
| 默认启用启发式并行度 | 默认不启用启发式并行度 | 配置 `profile.build.enable-heuristic-parallelism = true` |
| `cjo` 格式一致，可以增量编译 | `cjo` 格式不一致，增量编译失败 | 执行 clean 后重编译 |
| 如下配置不会报错：<br>`[package.package-configuration.xxx]`<br>`...`<br><br>`[package]`<br>`package-configuration = {}` | 该配置会报重复配置错误<br>其余类似结构的字段也会报错 | 删除空` package-configuration` 配置 |

### cjdb

#### 新增特性

- 支持 `iOS`、`Android` 调试能力。
- 支持组织名语法。
- 支持 `try`、`coalescing`、流、模式匹配、问号表达式求值。
- 支持 `common/specific` 新语法。

### cjfmt

#### 新增特性

- 支持组织名语法。
- 支持 `common/specific` 新语法。

### cjlint

#### 新增特性

- 支持组织名语法。
- 支持 `common/specific` 新语法。

### cjcov

#### 新增特性

支持 `common/specific` 新语法。

### cjprof

#### 新增特性

- 提供 `Windows`、`macOS` 版本 `cjprof`
- 堆快照分析展示能力增强

### HLE

该工具为第一次发布。

#### 新增特性

- 支持根据 `ArkTS` 头文件生成互操作胶水层代码。
- 支持根据 `C` 头文件生成互操作胶水层代码。

## 文档变更说明

### 开发指南

- 跨平台：新增跨平台特性文档“仓颉-Java 互操作”、“仓颉-ObjC 互操作”。
- cjc 编译选项：新增实验性编译选项“--compile-target=[exe|staticlib|dylib] <sup>[frontend]</sup>”的说明文档。
- cjc 编译选项：新增编译选项“--pgo-instr-gen=<.profraw>”的说明文档。

### 标准库API

- 仓颉编程语言标准库概述章节“平台支持说明”小节。
- 全量补充标准库 API 相关示例，帮助开发者使用 API。
- 根据 API 变更情况，补充修改 std.ast、std.collection、std.convert、std.core、std.interop、std.reflect、std.runtime 对应 API 文档。

### 工具

- 项目管理工具 cjpm：新增 Linux/macOS 平台“不支持带 `\` 路径”的限制说明；新增 global.strict-tls 配置项说明。
- 静态检查工具 cjlint：修正“规则级告警屏蔽”小节关于 SDK 路径的描述。
- 覆盖率统计工具 cjcov：修改 llvm 存放路径，由 work/cangjie/bin/llvm 修改为 work/cangjie/third_party/llvm。


