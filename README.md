# Cangjie Programming Language Documentation

[查看中文](./README_zh.md)

Cangjie programming language is a general programming language for full-scene application development, balancing development efficiency and runtime performance, and providing a good programming experience.

This repository stores the developer documentation for Cangjie programming language. Welcome to read the documentation, participate in the Cangjie developer documentation open-source project, and jointly improve the developer documentation.

## Introduction

Cangjie provides the following developer documentation:

- Cangjie Programming Language Development Guide: Introduces Cangjie syntax, compilation, and build content.
- Cangjie Programming Language Tools Usage Guide: Introduces the tools provided by Cangjie, including the project management tool `cjpm`, debugging tool `cjdb`, formatting tool `cjfmt` , hyper-language extension `HLE` and the language server tool `LSP`.
- Cangjie Programming Language Standard Library API: Provides a reference for the Cangjie standard library API, including API functions, parameters, return values, examples, etc. Please obtain this document from the cangjie_runtime repository.
- Cangjie Programming Language Extension Library API: Provides a reference for the Cangjie extension library API, including API functions, parameters, return values, examples, etc. Please obtain this document from the cangjie_stdx repository.

## Directory

The directory structure of this repository is as follows:

```text
.
└── docs
    ├── cmd-tools    # This directory stores the Cangjie programming language command-line tool usage guide
    └── dev-guide    # This directory stores the Cangjie programming language development guide
```

## Documentation versions and branches

Branches may change with releases. Verify the current list with `git branch -a`. The table below groups branches by purpose.

### Main branch

| Branch | Purpose |
|--------|---------|
| [main](https://atomgit.com/Cangjie/cangjie_docs/tree/main) | Default branch; baseline for day-to-day collaboration and merges |

### Development branch

| Branch | Purpose |
|--------|---------|
| [dev](https://atomgit.com/Cangjie/cangjie_docs/tree/dev) | Ongoing development and pre-integration |

### Release branches

| Branch | Cangjie version | Notes |
|--------|----------------|-------|
| [release/1.1](https://atomgit.com/Cangjie/cangjie_docs/tree/release%2F1.1) | 1.1.x STS | Documentation for the 1.1 line |
| [release/1.0](https://atomgit.com/Cangjie/cangjie_docs/tree/release%2F1.0) | 1.0.x LTS | Documentation for the 1.0 line |
| [release/v1.0.3-cjmp-beta](https://atomgit.com/Cangjie/cangjie_docs/tree/release%2Fv1.0.3-cjmp-beta) | 1.0.3 cjmp | cjmp beta documentation |

### OpenHarmony-aligned branches

| Branch | OH version | Notes |
|--------|-----------|-------|
| [release/OpenHarmony-release-6.0.2](https://atomgit.com/Cangjie/cangjie_docs/tree/release%2FOpenHarmony-release-6.0.2) | OpenHarmony 6.0.2 | Documentation aligned with OH 6.0.2 |
| [release/OpenHarmony-release-6.0](https://atomgit.com/Cangjie/cangjie_docs/tree/release%2FOpenHarmony-release-6.0) | OpenHarmony 6.0 | Documentation aligned with OH 6.0 |

> **Note**: The `/` in branch names is encoded as `%2F` in URLs. Links above are pre-encoded.

## License

Please refer to the [License](./LICENSE) for the Cangjie developer documentation license.

## Contribution

You are welcome to contribute. We encourage developers to participate in documentation feedback and contributions in various ways.

You can evaluate existing documentation, make simple changes, provide feedback on documentation quality issues, contribute your original content, etc. Refer to [CONTRIBUTING](./CONTRIBUTING.md).

## Related Repositories

- [**cangjie_docs**](https://atomgit.com/Cangjie/cangjie_docs)
- [cangjie_runtime](https://atomgit.com/Cangjie/cangjie_runtime)
- [cangjie_stdx](https://atomgit.com/Cangjie/cangjie_stdx)
