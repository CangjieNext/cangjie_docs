func foo(a: () -> Unit){
    // 业务逻辑处理
}

class A {
    public static var ctx: Int64 // 编译报错，静态变量 ctx 没有初始化

    static init() {
        let lambda = {=> ctx = 10}
        foo(lambda)
    }
}

main() {}