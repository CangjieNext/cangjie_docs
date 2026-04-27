unsafe {
    let array = Array<UInt8>(4, repeat: 0)
    let cp = acquireArrayRawData(array)

    // array 数组实际可访问的范围是 [0, 4)，而下述写操作访问了第 6 个字节，导致仓颉堆内存向前溢出 2 个字节。错误报告中使用 array[size+1] 表示该向后越界行为。
    cp.pointer.write(5, 2)
    releaseArrayRawData(cp)
}