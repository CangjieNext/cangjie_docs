# 关键字

关键字是不能作为标识符使用的特殊字符串，仓颉语言的关键字如下表所示：

| 关键字          | 关键字        | 关键字       |
|--------------|------------|-----------|
| as           | abstract   | break     |
| Bool         | case       | catch     |
| class        | const      | continue  |
| Rune         | do         | else      |
| enum         | extend     | for       |
| func         | false      | finally   |
| foreign      | Float16    | Float32   |
| Float64      | if         | in        |
| is           | init       | import    |
| interface    | Int8       | Int16     |
| Int32        | Int64      | IntNative |
| let          | mut        | main      |
| macro        | match      | Nothing   |
| open         | operator   | override  |
| prop         | public     | package   |
| private      | protected  | quote     |
| redef        | return     | spawn     |
| super        | static     | struct    |
| synchronized | try        | this      |
| true         | type       | throw     |
| This         | unsafe     | Unit      |
| UInt8        | UInt16     | UInt32    |
| UInt64       | UIntNative | var       |
| VArray       | where      | while     |
| exclave      | demode     |           |

其中 `exclave`、`demode` 用于模态类型，详见[模态类型](../modal_type/modal_overview.md)章节。这两个关键字始终生效，没有编译选项可以关闭；已有代码中如果用 `exclave` 或 `demode` 作为标识符，需要改写为原始标识符，如 `` `exclave` ``，参见[标识符](../basic_programming_concepts/identifier.md)。

`local` 不是关键字，只有出现在模态类型的 `@` 之后时才表示模式，在其他位置仍可作为普通标识符使用。
