class Counter {
    var total = 0
    init(data: Array<Int64>) { total = data.size }
    operator func ()(data: Array<Int64>) { total += data.size }
}

main() {
    let counter = Counter(1, 2)
    println(counter.total)
    counter(3, 4, 5)
    println(counter.total)
}