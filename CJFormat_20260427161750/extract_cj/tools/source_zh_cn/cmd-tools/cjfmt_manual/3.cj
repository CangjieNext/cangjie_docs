enum TimeUnit { // 符合：跟随声明放行末，前置 1 空格
    Year | Month | Day | Hour
} // 符合：右大括号独占一行

class A { // 符合：跟随声明放行末，前置 1 空格
    var count = 1
}

func fn(a: Int64): Unit { // 符合：跟随声明放行末，前置 1 空格
    if (a > 0) { // 符合：跟随声明放行末，前置 1 空格
    // CODE
    } else { // 符合：右大括号和 else 在同一行
        // CODE
    } // 符合：右大括号独占一行
}

// lambda 函数
let add = {
    base: Int64, bonus: Int64 => // 符合: lambda 表达式中非空块遵循 K&R 风格
    print("符合 news")
    base + bonus
}
