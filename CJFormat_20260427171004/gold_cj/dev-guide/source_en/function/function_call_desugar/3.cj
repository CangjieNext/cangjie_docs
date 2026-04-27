func inc(x: Array<Int64>): Array<Int64> { // Increasing the value of each element in the array by '1'
    let s = x.size
    var i = 0
    for (e in x where i < s) {
        x[i] = e + 1
        i++
    }
    x
}

func sum(y: Array<Int64>): Int64 { // Get the sum of elements in the array
    var s = 0
    for (j in y) {
        s += j
    }
    s
}

let arr: Array<Int64> = [1, 3, 5]
let res = arr |> inc |> sum // res = 12
