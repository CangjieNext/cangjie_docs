var a: VArray<Int32, $3> = [1, 2, 3]
unsafe {
    cfoo1(inout a)
    cfoo2(inout a)
}