foreign func strlen(s: CString): UIntNative

main() {
    var s1 = unsafe { LibC.mallocCString("hello") }
    var s2 = unsafe { LibC.mallocCString("world") }

    let t1: Int64 = s1.size()
    let t2: Bool = s2.isEmpty()
    let t3: Bool = s1.equals(s2)
    let t4: Bool = s1.startsWith(s2)
    let t5: Int32 = s1.compare(s2)

    let length = unsafe { strlen(s1) }

    unsafe {
        LibC.free(s1)
        LibC.free(s2)
    }
}
