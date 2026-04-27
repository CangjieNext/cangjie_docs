// VArray<T, $N>(initElement: (Int64) -> T)
let b = VArray<Int64, $5>({i => i}) // [0, 1, 2, 3, 4]
// VArray<T, $N>(repeat!: T)
let c = VArray<Int64, $5>(repeat: 0) // [0, 0, 0, 0, 0]
