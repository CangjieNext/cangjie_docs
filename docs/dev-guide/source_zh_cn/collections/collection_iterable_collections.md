# Iterable 和 Collections

前面已经了解过Range、Array、ArrayList，它们都可以使用for-in进行遍历操作。对于开发者自定义的类型，也能实现类似的遍历操作。

Range、Array、ArrayList都是通过Iterable来支持for-in语法的。

Iterable是如下形式（只展示了核心代码）的一个内置interface。

```cangjie
public interface Iterable<T> {
    func iterator(): Iterator<T>
    ...
}
```

iterator函数要求返回的Iterator类型是如下形式（只展示了核心代码）的另一个内置abstract class。

```cangjie
public abstract class Iterator<T> <: Iterable<T> {
    public func next(): Option<T>
    ...
}
```

可以使用for-in语法来遍历任何一个实现了Iterable接口类型的实例。

假设有这样一段for-in代码，如下所示。

<!-- run -->

```cangjie
let list = [1, 2, 3]
for (i in list) {
    println(i)
}
```

它等价于如下形式的while代码。

<!-- run -->

```cangjie
let list = [1, 2, 3]
var it = list.iterator()
while (true) {
    match (it.next()) {
        case Some(i) => println(i)
        case None => break
    }
}
```

另外一种常见的遍历Iterable类型的方法是在while表达式的条件中使用模式匹配，比如上面while代码的另一种等价写法是：

<!-- run -->

```cangjie
let list = [1, 2, 3]
var it = list.iterator()
while (let Some(i) <- it.next()) {
    println(i)
}
```

Array、ArrayList、HashSet、HashMap类型都实现了Iterable，因此可以将其用在for-in或者while中。
