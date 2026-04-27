
main(): Int64 {
    let tl = ThreadLocal<Int64>()
    let fut1 = spawn {
        tl.set(123)
        println("tl in spawn1 = ${tl.get().getOrThrow()}")
    }
    let fut2 = spawn {
        tl.set(456)
        println("tl in spawn2 = ${tl.get().getOrThrow()}")
    }
    fut1.get()
    fut2.get()
    0
}