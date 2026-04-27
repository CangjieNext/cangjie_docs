main() {
    let arr = [0, 1, 2]
    let a = arr[0] // a == 0
    let b = arr[1] // b == 1
    let c = arr[-1] // array size is '3', but access index is '-1', which would overflow
}
