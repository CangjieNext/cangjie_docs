main(): Int64 {
    let fut: Future<Int64> = spawn {
        sleep(Duration.second) // sleep for 1s.
        return 1
    }

    try {
        // wait for the thread to finish, and get the result.
        let res: Int64 = fut.get()
        println("result = ${res}")
    } catch (_) {
        println("oops")
    }
    return 0
}