let list = [1, 2, 3]
var it = list.iterator()
while (let Some(i) <- it.next()) {
    println(i)
}