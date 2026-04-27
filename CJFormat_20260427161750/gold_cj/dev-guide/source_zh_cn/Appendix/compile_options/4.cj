foreign func printHello(): Unit

main(): Int64 {
    unsafe {
        printHello()
    }
    return 0
}
