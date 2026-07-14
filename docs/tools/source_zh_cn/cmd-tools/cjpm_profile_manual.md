# cjpm profile 使用说明

`cjpm profile` 用于在构建项目时采集编译耗时数据，并将结果写入指定目录。该命令适用于定位构建耗时较高的包和模块。

## 基本用法

```bash
cjpm profile --output build/profile
```

执行完成后，分析结果会生成到 `build/reports/profile` 目录中。默认情况下，该目录会包含 `summary.json` 和 `detail.csv` 两个文件。

## 参数说明

| 参数 | 说明 |
| --- | --- |
| `--output <path>` | 指定 profile 报告输出目录。未指定时输出到 `build/profile`。 |
| `--format <type>` | 指定报告格式，可选值为 `json`、`csv`。 |
| `--clean` | 运行前删除已有的 profile 报告。 |

## 示例

生成 JSON 报告：

```bash
cjpm profile --format json --output build/profile
```

生成 CSV 报告：

```bash
cjpm profile --format csv --output build/profile.csv
```

如果同时指定 `--format json` 和 `--format csv`，命令会优先生成 CSV 报告。

## 注意事项

`cjpm profile` 不会改变构建产物，只会生成分析报告。

### Windows 平台

待补充。
