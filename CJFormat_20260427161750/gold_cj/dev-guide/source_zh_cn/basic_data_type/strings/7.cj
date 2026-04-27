main() {
    var s1 = "abc"
    var s2 = "ABCabc"
    var s3 = "abcyyabcqqabcbc"
    let r1 = s2.contains(s1) // 判断s2中是否包含字符串s1
    println(r1) // true
    let r2 = s3.split(s1) //对原字符串 s3 按照字符串 s1 分隔符分割，指定是否删除空串
    println(r2[1]) // yy
    s1 = s2
    println(s1) // ABCabc
}
