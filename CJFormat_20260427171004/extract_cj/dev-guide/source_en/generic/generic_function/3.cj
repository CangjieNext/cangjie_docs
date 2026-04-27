func times2(a: Int64): Int64 {
    return a * 2
}

func plus10(a: Int64): Int64 {
    return a + 10
}

func times2plus10(a: Int64) {
    return composition<Int64, Int64, Int64>(times2, plus10)(a)
}

main() {
  println(times2plus10(9))
}