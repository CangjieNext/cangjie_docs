main() {
    let a: Int8 = 10
    let b: Int16 = 20
    let r1 = Int16(a)
    println("The type of r1 is 'Int16', and r1 = ${r1}")
    let r2 = Int8(b)
    println("The type of r2 is 'Int8', and r2 = ${r2}")

    let c: Float32 = 1.0
    let d: Float64 = 1.123456789
    let r3 = Float64(c)
    println("The type of r3 is 'Float64', and r3 = ${r3}")
    let r4 = Float32(d)
    println("The type of r4 is 'Float32', and r4 = ${r4}")

    let e: Int64 = 1024
    let f: Float64 = 1024.1024
    let r5 = Float64(e)
    println("The type of r5 is 'Float64', and r5 = ${r5}")
    let r6 = Int64(f)
    println("The type of r6 is 'Int64', and r6 = ${r6}")
}