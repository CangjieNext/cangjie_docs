// Range<T>(start: T, end: T, step: Int64, hasStart: Bool, hasEnd: Bool, isClosed: Bool)
let r1 = Range<Int64>(0, 10, 1, true, true, true) // r1 contains 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
let r2 = Range<Int64>(0, 10, 1, true, true, false) // r2 contains 0, 1, 2, 3, 4, 5, 6, 7, 8, 9
let r3 = Range<Int64>(10, 0, -2, true, true, false) // r3 contains 10, 8, 6, 4, 2