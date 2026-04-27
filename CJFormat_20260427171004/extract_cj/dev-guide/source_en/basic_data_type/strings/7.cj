main() {
    var s1 = "abc"
    var s2 = "ABCabc"
    var s3 = "abcyyabcqqabcbc"
    let r1 = s2.contains(s1)    // Checks if s2 contains the string s1
    println(r1)                 // true
    let r2 = s3.split(s1)       // Splits the original string s3 using s1 as the delimiter
    println(r2[1])              // yy
    s1 = s2
    println(s1)                 // ABCabc
}