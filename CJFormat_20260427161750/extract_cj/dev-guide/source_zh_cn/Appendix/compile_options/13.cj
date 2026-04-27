import stdx.effect.Command

// 定义一个名为 GetNumber 的 Command
class GetNumber <: Command<Int64> {}

main() {
    try {
        println("About to perform")

        // 执行 GetNumber 效应
        let a = perform GetNumber()

        // handler 恢复后将从此处继续执行
        println("It is resumed, a = ${a}")
    } handle(e: GetNumber) {
        // 处理 GetNumber 效应
        println("It is performed")

        // 恢复执行，并注入值 9
        resume with 9
    }
    0
}