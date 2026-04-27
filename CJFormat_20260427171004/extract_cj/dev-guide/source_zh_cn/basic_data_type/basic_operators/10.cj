main(): Int64 {
    let v1 = Option<Int64>.Some(100)
    let v2 = Option<Int64>.None
    let r1 = v1 ?? 0
    let r2 = v2 ?? 0
    print("${r1}") // 100
    print("${r2}") // 0
    return 0
}