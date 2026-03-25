# Cangjie Release Notes

## 版本介绍

 `Cangjie 1.1.0-beta.23` 为 `STS 1.1.0` 第一个公测版本。

相比 `LTS 1.0.5` 版本, 该版本新增中心仓支持、跨平台(实验特性)等基础特性，修复了若干bug。详见后续章节介绍。

## 编译器

### 新增特性

- 支持 MacOS/Windows 全静态链接
- 支持 weak reference 编译选项
- 支持前向 `CFI`
- 支持 Common/Specific 特性(实验特性)
- 支持组织名语法
- release 版本增加 `dump` 调测能力
- 支持 `Android` 、`iOS` 交叉编译

### 变更特性
  Windows 构建变更为 LLVM-MinGW

## 运行时

### 新增特性

- 支持在 Android 8.0, iOS 12 及以上系统运行
- 仓颉程序在 `iOS` 平台运行时，支持未捕获异常处理

## 标准库

### 新增特性

 - `Array<Byte>` 支持无拷贝转 `String`
 - `http` 支持主动关闭连接和判断连接是否关闭
 - 反射新增支持 `struct`反射、标准库反射、泛型实例化、`函数\闭包`、`tuple`、 `enum`

### 变更特性
- `Frozen` 函数异常信息修改
- 异常链和反射新增私有变量，不兼容 `1.0.5` 的 `ABI` 

## 工具链

### IDE插件

#### 新增特性

- 支持 Common/Specific 语法
- 支持增量代码诊断
- 支持组织名新语法

### cjpm

#### 新增特性

- 支持中心仓
- 支持源码增量扫描
- 支持工程 `LTO`
- 支持透传 `cjc` 编译并行度
- 支持包并行编译
- 支持制品包上传、下载

#### 变更特性

|变更前|变更后|适配举例|
|---|---|--|
| version 不校验 | 该字段用于中心仓校验  | 删除无效的 version 字段  |  

### cjdb

#### 新增特性

- 支持 `iOS` 真机调试
- 支持 `Common\Specific` 语法
- 支持`coalecsing`、 `try`表达式、流表达式、模式匹配、问号操作符的调试 

### cjfmt

#### 新增特性

支持 `Common\Specific` 语法

### cjlint

#### 新增特性

支持 `Common\Specific` 语法

### cjcov

#### 新增特性

支持 `Common\Specific` 语法
