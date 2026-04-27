var isPresent: Bool = false  // 符合：变量声明冒号之后有一个空格
func method(isEmpty!: Bool): RetType { ... } // 符合：函数定义（命名参数 / 返回类型）中的冒号之后有一个空格

method(isEmpty: isPresent) // 符合: 命名参数传值中的冒号之后有一个空格

0..MAX_COUNT : -1 // 符合: range 操作符区间前后没有空格，步长冒号前后两侧有一个空格

var hundred = 0
do { // 符合：关键字 do 和后面的括号之间有一个空格
    hundred++
} while (hundred < 100) // 符合：关键字 while 和前面的括号之间有一个空格

func fn(paramName1: ArgType, paramName2: ArgType): ReturnType { // 符合：圆括号和内部相邻字符之间不出现空格
    ...
    for (i in 1..4) { // 符合：range 操作符左右两侧不留空格
        ...
    }
}

let listOne: Array<Int64> = [1, 2, 3, 4] // 符合：方括号和圆括号内部两侧不出现空格

let salary = base + bonus // 符合：二元操作符左右两侧留空格

x++ // 符合：一元操作符和操作数之间不留空格