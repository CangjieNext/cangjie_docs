func f(fn: (Int64) -> Int64) {
    fn(1)
}

func test() {
    f {i => i * i}
}
