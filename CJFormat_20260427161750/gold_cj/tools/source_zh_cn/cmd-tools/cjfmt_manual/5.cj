class MyApp <: App {
    let album = albumCreate()
    let page: Router
    // 空行
    // 空行
    // 空行
    init() { // 不符合：类型定义内部使用连续空行
        this.page = Router("album", album)
    }

    override func onCreate(): Unit {
        println("album Init.") // 不符合：大括号内部首尾存在空行

    }
}
