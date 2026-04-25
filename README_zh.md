# 仓颉编程语言文档

[View English](./README.md)

仓颉编程语言是一种面向全场景应用开发的通用编程语言，可以兼顾开发效率和运行性能，并提供良好的编程体验。

本仓库存放仓颉编程语言开发者文档。欢迎阅读文档，参与仓颉开发者文档开源项目，共同完善开发者文档。

## 简介

仓颉提供如下开发者文档：

- 仓颉编程语言开发指南：介绍仓颉语法、编译构建等内容。
- 仓颉编程语言工具使用指南：介绍仓颉提供的工具，包括项目管理工具`cjpm` 、调试工具 `cjdb` 、格式化工具 `cjfmt` 、语言扩展工具 `HLE` 和语言服务器工具 `LSP`。
- 仓颉编程语言标准库 API：提供仓颉标准库 API 参考，包括 API 功能、参数、返回值、示例等。该文档请至 cangjie_runtime 仓库获取。
- 仓颉编程语言扩展库 API：提供仓颉扩展库 API 参考，包括 API 功能、参数、返回值、示例等。该文档请至 cangjie_stdx 仓库获取。

## 目录

本仓库目录如下：

```text
.
└── docs
    ├── cmd-tools    # 该目录存放仓颉编程语言命令行工具使用指南
    └── dev-guide    # 该目录存放仓颉编程语言开发指南
```

## 文档版本与分支说明

本仓库当前远程分支以 [cangjie_docs](https://atomgit.com/Cangjie/cangjie_docs) 为准，按用途示例如下（以实际 `git branch -a` 为准并会随发版增删）：

### 主分支

- [main](https://atomgit.com/Cangjie/cangjie_docs/tree/main)：默认主分支，日常协作与合入建议以该分支为基线。

### 开发分支

- [dev](https://atomgit.com/Cangjie/cangjie_docs/tree/dev)：开发分支，用于主线的持续开发或预集成。

### 发版与配套分支

- [release/1.1](https://atomgit.com/Cangjie/cangjie_docs/tree/release%2F1.1)：1.1 线文档发布分支。
- [release/1.0](https://atomgit.com/Cangjie/cangjie_docs/tree/release%2F1.0)：1.0 线文档发布分支。
- [release/v1.0.3-cjmp-beta](https://atomgit.com/Cangjie/cangjie_docs/tree/release%2Fv1.0.3-cjmp-beta)：`v1.0.3` cjmp 相关 beta 线文档。

### OpenHarmony 配套文档

- [release/OpenHarmony-release-6.0.2](https://atomgit.com/Cangjie/cangjie_docs/tree/release%2FOpenHarmony-release-6.0.2)：与 OpenHarmony 6.0.2 线配套的本仓库文档分支。
- [release/OpenHarmony-release-6.0](https://atomgit.com/Cangjie/cangjie_docs/tree/release%2FOpenHarmony-release-6.0)：与 OpenHarmony 6.0 线配套的本仓库文档分支。

## 许可证

仓颉开发者文档许可证请参见 [License](./LICENSE) 。

## 贡献

欢迎您参与贡献，我们鼓励开发者以各种方式参与文档反馈和贡献。

您可以对现有文档进行评价、简单更改、反馈文档质量问题、贡献您的原创内容，详情请参考[贡献文档](./CONTRIBUTING_zh.md)。

## 相关仓

- [**cangjie_docs**](https://atomgit.com/Cangjie/cangjie_docs)
- [cangjie_runtime](https://atomgit.com/Cangjie/cangjie_runtime)
- [cangjie_stdx](https://atomgit.com/Cangjie/cangjie_stdx)
