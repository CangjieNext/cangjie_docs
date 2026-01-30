# HashMap

使用HashMap类型需要导入collection包：

<!-- run -->

```cangjie
import std.collection.*
```

可以使用HashMap类型来构造元素为键值对的Collection。

HashMap是一种哈希表，提供对其包含的元素的快速访问。表中的每个元素都使用其键作为标识，可以使用键来访问相应的值。

仓颉使用 `HashMap<K, V>` 表示HashMap类型，K表示HashMap的键类型，K必须是实现了Hashable和 `Equatable<K>` 接口的类型，例如数值或String。V表示HashMap的值类型，V可以是任意类型。

<!-- compile.error -hashmap1 -->

```cangjie
var a: HashMap<Int64, Int64> = HashMap<Int64, Int64>() // HashMap whose key type is Int64 and value type is Int64
var b: HashMap<String, Int64> = HashMap<String, Int64>() // HashMap whose key type is String and value type is Int64
```

元素类型不相同的HashMap是不相同的类型，所以它们之间不可以互相赋值。

因此以下例子是不合法的。

<!-- compile.error -hashmap1 -->

```cangjie
b = a // Type mismatch
```

仓颉中可以使用构造函数的方式构造一个指定的HashMap。

<!-- run -->

```cangjie
let a = HashMap<String, Int64>() // Created an empty HashMap whose key type is String and value type is Int64
let b = HashMap<String, Int64>([("a", 0), ("b", 1), ("c", 2)]) // whose key type is String and value type is Int64, containing elements ("a", 0), ("b", 1), ("c", 2)
let c = HashMap<String, Int64>(b) // Use another Collection to initialize a HashMap
let d = HashMap<String, Int64>(10) // Created a HashMap whose key type is String and value type is Int64 and capacity is 10
let e = HashMap<Int64, Int64>(10, {x: Int64 => (x, x * x)}) // Created a HashMap whose key and value type is Int64 and size is 10. All elements are initialized by specified rule function
```

## 访问 HashMap 成员

当需要对HashMap的所有元素进行访问时，可以使用for-in循环遍历HashMap的所有元素。

需要注意的是，HashMap并不保证按插入元素的顺序排列，因此遍历的顺序和插入的顺序可能不同。

<!-- verify -->

```cangjie
import std.collection.HashMap

main() {
    let map = HashMap<String, Int64>([("a", 0), ("b", 1), ("c", 2)])
    for ((k, v) in map) {
        println("The key is ${k}, the value is ${v}")
    }
}
```

编译并执行上面的代码，有可能会输出：

```text
The key is a, the value is 0
The key is b, the value is 1
The key is c, the value is 2
```

当需要知道某个HashMap包含的元素个数时，可以使用size属性获得对应信息。

<!-- verify -->

```cangjie
import std.collection.HashMap

main() {
    let map = HashMap<String, Int64>([("a", 0), ("b", 1), ("c", 2)])
    if (map.size == 0) {
        println("This is an empty hashmap")
    } else {
        println("The size of hashmap is ${map.size}")
    }
}
```

编译并执行上面的代码，会输出：

```text
The size of hashmap is 3
```

当想判断HashMap中是否包含某个键时，可以使用contains函数。如果该键存在会返回true，否则返回false。

<!-- run -->

```cangjie
let map = HashMap<String, Int64>([("a", 0), ("b", 1), ("c", 2)])
let a = map.contains("a") // a == true
let b = map.contains("d") // b == false
```

当想访问指定键对应的元素时，可以使用下标语法访问（下标的类型必须是键类型）。使用不存在的键作为索引会触发运行时异常。

<!-- run.error -->

```cangjie
let map = HashMap<String, Int64>([("a", 0), ("b", 1), ("c", 2)])
let a = map["a"] // a == 0
let b = map["b"] // b == 1
let c = map["d"] // Runtime exceptions
```

## 修改 HashMap

HashMap是一种可变的引用类型，HashMap类型提供了修改元素、添加元素、删除元素的功能。

HashMap的可变性是一个非常有用的特征，可以让同一个HashMap实例的所有引用都共享同样的元素，并且对它们统一进行修改。

可以使用下标语法对某个键对应的值进行修改。

<!-- run -->

```cangjie
let map = HashMap<String, Int64>([("a", 0), ("b", 1), ("c", 2)])
map["a"] = 3
```

HashMap是引用类型，HashMap在作为表达式使用时不会拷贝副本，同一个HashMap实例的所有引用都会共享同样的数据。

因此对HashMap元素的修改会影响到该实例的所有引用。

<!-- run -->

```cangjie
let map1 = HashMap<String, Int64>([("a", 0), ("b", 1), ("c", 2)])
let map2 = map1
map2["a"] = 3
// map1 contains the elements ("a", 3), ("b", 1), ("c", 2)
// map2 contains the elements ("a", 3), ("b", 1), ("c", 2)
```

如果需要将单个键值对添加到HashMap里，请使用add函数。如果希望同时添加多个键值对，可以使用 `add(all!: Collection<(K, V)>)` 函数。当键不存在时，add函数会执行添加的操作，当键存在时，add函数会将新的值覆盖旧的值。

<!-- run -->

```cangjie
let map = HashMap<String, Int64>()
map.add("a", 0) // map contains the element ("a", 0)
map.add("b", 1) // map contains the elements ("a", 0), ("b", 1)
let map2 = HashMap<String, Int64>([("c", 2), ("d", 3)])
map.add(all: map2) // map contains the elements ("a", 0), ("b", 1), ("c", 2), ("d", 3)
```

除了使用add函数以外，也可以使用赋值的方式直接将新的键值对添加到HashMap。

<!-- run -->

```cangjie
let map = HashMap<String, Int64>([("a", 0), ("b", 1), ("c", 2)])
map["d"] = 3 // map contains the elements ("a", 0), ("b", 1), ("c", 2), ("d", 3)
```

从HashMap中删除元素，可以使用remove函数，需要指定删除的键。

<!-- run -->

```cangjie
let map = HashMap<String, Int64>([("a", 0), ("b", 1), ("c", 2), ("d", 3)])
map.remove("d") // map contains the elements ("a", 0), ("b", 1), ("c", 2)
```
