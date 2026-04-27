unsafe {
    var array = Array<UInt8>(4, repeat: 1)
    var cp = acquireArrayRawData<UInt8>(array)
    cp.pointer.write(-1, 2)
    releaseArrayRawData(cp)
}