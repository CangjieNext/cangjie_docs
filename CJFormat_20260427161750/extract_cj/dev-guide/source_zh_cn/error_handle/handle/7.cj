interface Resource {
    func isClosed(): Bool // 离开 try-with-resources 作用域时，判断是否需要调用 close 函数释放资源
    func close(): Unit // 在 isClosed 返回 false 的场景下释放资源。
}