class C {
    var p: CString

    init(s: String) {
        p = unsafe { LibC.mallocCString(s) }
        println(s)
    }
    ~init() {
        unsafe { LibC.free(p) }
    }
}
