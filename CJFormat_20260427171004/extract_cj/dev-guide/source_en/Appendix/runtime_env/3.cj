unsafe {
    let array = Array<UInt8>(4, item: 0)
    let cp = acquireArrayRawData(array)
    cp.pointer.read()

    // Missing releaseArrayRawData
    return
}