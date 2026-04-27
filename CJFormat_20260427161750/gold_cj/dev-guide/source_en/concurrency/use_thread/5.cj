main(): Int64 {
    let fut = spawn {
        sleep(Duration.second) // sleep for 1s.
        return 1
    }

    // wait for the thread to finish, but only for 1ms.
    try {
        let res = fut.get(Duration.millisecond * 1)
        println("result: ${res}")
    } catch (_: TimeoutException) {
        println("oops")
    }
    return 0
}
