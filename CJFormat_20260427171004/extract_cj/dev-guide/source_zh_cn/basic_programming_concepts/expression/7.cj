main() {
    let a = Some(3)
    let c = if (let Some(b) <- a) {
            1 // 模式匹配成功，c = 1
        } else {
            2
        }
    let d = Some(1)

    if (let Some(e) <- a && let Some(f) <- d) { // 两种模式都匹配，条件的值为真
        println("${e} ${f}") // print 3 1
    }

    if (let Some(f) <- d && f > 3) { // 模式匹配；f = 1，f > 3 检查失败，跳转到 else 分支
        println("${f}")
    } else {
        println("d is None or value of d is less or equal to 3") // 打印该行
    }

    if (let Some(_) <- a || let Some(_) <- d) { // 枚举模式通过||连接，没有变量绑定，正确
        println("at least one of a and d is Some") // 打印该行
    } else {
        println("both a and d are None")
    }

    let g = 3
    if (let Some(_) <- a || g > 1) {
        println("this") // 打印该行
    } else {
        println("that")
    }
}