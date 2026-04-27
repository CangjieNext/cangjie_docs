unsafe {
    let array = Array<UInt8>(4, item: 0)
    let cp = acquireArrayRawData(array)

    // The valid access range for the array is [0, 4). The following write operation accesses the 6th byte, causing a 2-byte backward out-of-bounds violation. The error report uses array[size+1] to indicate this behavior.
    cp.pointer.read(5)
    releaseArrayRawData(array)
}