main() {
    for (i in 0..8 where i % 2 == 1) { // i 为奇数才会执行循环体
        println(i)
    }
}
