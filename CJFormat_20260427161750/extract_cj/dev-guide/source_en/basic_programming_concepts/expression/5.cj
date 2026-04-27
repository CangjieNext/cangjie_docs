var a = 10
var b = if(a == 10) { // Error, types Struct-String and Int64 of the two branches of this 'if' expression mismatch
    "this is 10"
}else {
    20
}