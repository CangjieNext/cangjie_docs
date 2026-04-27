main() {
    for (i in 0..5) {
        i = i * 10 // 错误，不能对已初始化的 `let` 常量赋值
        println(i)
    }
}
