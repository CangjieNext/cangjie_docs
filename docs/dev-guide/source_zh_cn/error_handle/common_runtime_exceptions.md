# 常见运行时异常

仓颉语言内置了常见的异常类，开发者可直接使用。

| 异常                              | 描述                                              |
| :-------------------------------- | :------------------------------------------------ |
| `ConcurrentModificationException` | 并发修改产生的异常                                |
| `IllegalArgumentException`        | 传递不合法或不正确参数时抛出的异常                |
| `NegativeArraySizeException`      | 创建大小为负的数组时抛出的异常                    |
| `NoneValueException`              | 值不存在时产生的异常，如 Map 中不存在要查找的 key |
| `OverflowException`               | 算术运算溢出异常                                  |
