class ListItem {
    var content: Array<Int64> // 符合：相对类声明缩进 4 个空格
    init(
        content: Array<Int64>, // 符合：函数参数相对函数声明缩进 4 个空格
        isShow!: Bool = true,
        id!: String = ""
    ) {
        this.content = content
    }
}
