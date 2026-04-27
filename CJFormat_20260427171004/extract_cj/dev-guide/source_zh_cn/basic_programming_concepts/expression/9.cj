if (let Some(a) <- b || a > 1) {} // 由 `||` 连接的条件不能使用会绑定变量的 enum 模式
if (let Some(a) <- b && a + 1) {} // `&&` 右侧既不是 let pattern，也不是类型为 Bool 的普通表达式
if (a > 3 && let Some(a) <- b) {} // a 由 Some(a) pattern 绑定，不能在绑定它的 pattern 左侧使用
if (let Some(a) <- b && a > 3) {
    println("${a} > 3")
} else {
    println("${a} < 3") // a 只能在 if 分支使用，不能在 else 分支使用
}
if (let Some(a) <- b where a > 3) {} // 使用 `&&` 表示条件检查，而不是 `where`