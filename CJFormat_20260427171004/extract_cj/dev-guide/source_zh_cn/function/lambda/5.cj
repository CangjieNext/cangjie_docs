func f(a1: (Int64) -> Int64): Int64 {
  a1(1)
}

main(): Int64 {
  f({ a2: Int64 => a2 + 10 })
}