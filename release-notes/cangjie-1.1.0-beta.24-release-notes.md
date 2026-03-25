# Cangjie Release Notes

## 版本介绍

 `Cangjie 1.1.0-beta.24` 为 `STS 1.1.0` 第 2 个公测版本。

相比 `Cangjie 1.1.0-beta.23` 版本, 该版本无新增特性，修复了 Beta 期间发现的若干问题。

## 编译器

### 修复问题

- 修复 MacOS 交叉编译 iOS 时 LTO 报错问题
- 修复 `vfe` 问题

## 运行时

### 修复问题

修复运行时内存占用问题

## 工具链

### LSP

#### 修复问题

- 修复代码编辑时，文件所在包的代码提示问题
- 修复 `hide` 支持问题

### cjpm

#### 修复问题
- `TrustALL` 默认不开启，由用户控制
- `cangjie-repo.toml` 添加默认  `url`

### cjfmt

#### 修复问题

修复属性格式化问题

## 文档
 API 文档增加 `unitest`、 `fs`、 `time`、`runtime` 等库的  `API` 说明
