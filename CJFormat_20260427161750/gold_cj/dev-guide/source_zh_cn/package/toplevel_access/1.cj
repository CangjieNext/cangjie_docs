package a

private func f1() {
    1
} // f1 仅在当前文件内可见

func f2() {
    2
} // f2 仅当前包及子包内可见

protected func f3() {
    3
} // f3 仅当前模块内可见

public func f4() {
    4
} // f4 当前模块内外均可见
