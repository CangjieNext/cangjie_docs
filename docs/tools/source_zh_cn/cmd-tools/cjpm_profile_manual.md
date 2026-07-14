# cjpm profile 使用说明

`cjpm profile` 用于在构建项目时采集编译耗时数据，并将结果写入指定目录。该命令适用于定位构建耗时较高的包和模块。本文中 profile 报告、性能报告和分析结果表示同一种输出文件。

## 基本用法

```bash
cjpm profile --output build/profile
```

执行完成后，性能报告会生成到 `build/reports/profile` 目录中。默认情况下，分析结果会写入 `build/profile`，并包含 `summary.json` 和 `detail.csv` 两个文件。

## 参数说明

| 参数 | 说明 |
| --- | --- |
| `--output <path>` | 指定 profile 报告输出目录。未指定时输出到 `build/profile`。 |
| `--format <type>` | 指定报告格式，可选值为 `json`、`csv`。 |
| `--report-dir <path>` | 指定性能报告目录。未指定时输出到 `build/reports/profile`。 |
| `--clean` | 运行前删除已有的 profile 报告 |
| `--summary`

## 示例

生成 JSON 报告：

```bash
cjpm profile --format json --output build/profile
```

生成 CSV 报告：

```bash
cjpm profile --format csv --output build/profile.csv
```

如果同时指定 `--format json` 和 `--format csv`，命令会优先生成 CSV 报告。上文的 `--format <type>` 只接受一个取值。

## 注意事项

`cjpm profile` 不会改变构建产物，只会生成分析报告。该命令会清理 `build` 目录下的已有构建产物。

## 支持平台

该命令支持 Linux、macOS 和 Windows 平台。当前版本仅支持 Linux 平台。

### Windows 平台

待补充。
