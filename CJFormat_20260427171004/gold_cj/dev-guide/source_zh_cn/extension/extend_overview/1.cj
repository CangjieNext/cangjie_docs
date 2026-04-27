interface Foo {
    func printValue(a: Int64): Unit
}

class Boo {
    var boo: Int64 = 2
}

extend Boo {
    public prop x: Int64 { // 添加成员属性
        get() {
            123
        }
    }

    func newMember(): Unit {
        println("This is a member function of a new extension.") // 添加成员函数
    }

    public operator func -() {
        println("Overload the operator addition function.") // 添加操作符重载函数
        -x
    }
}

// 接口扩展，实现接口
extend<T> Array<T> <: Foo {
    public func printValue(a: Int64) {
        println("The is ${a}.")
    }
}
