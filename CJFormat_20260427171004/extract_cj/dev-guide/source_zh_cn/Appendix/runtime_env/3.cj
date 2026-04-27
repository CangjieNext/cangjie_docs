unsafe {
    let array = Array<UInt8>(4, repeat: 0)
    let cp = acquireArrayRawData(array)
    cp.pointer.read()

    // 未使用 releaseArrayRawData
    return
}