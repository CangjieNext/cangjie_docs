# I/O 节点流

节点流是指直接提供数据源的流，节点流的构造方式通常是依赖某种直接的外部资源（如文件、网络等）。

仓颉编程语言中常见的节点流包含标准流（ConsoleReader、ConsoleWriter）、文件流（File）、网络流（Socket）等。

本章介绍标准流和文件流。

## 标准流

标准流包含标准输入流、标准输出流和标准错误输出流。

标准流是程序与外部数据交互的标准接口。程序运行的时候从输入流读取数据，作为程序的输入，程序运行过程中输出的信息被传送到输出流，类似的，错误信息被传送到错误流。

在仓颉编程语言中可以使用 `getStdIn`、`getStdOut`、`getStdErr` 全局函数来分别获取这三个标准流。

使用上面的函数需要导入 `env` 包：

导入 env 包示例：

<!-- run -->

```cangjie
import std.env.*
```

`env` 包内的 `ConsoleReader` 和 `ConsoleWriter` 类型对这三个标准流都进行了易用性封装（标准错误输出流也是输出流，所以一共是两个类型），提供了更方便的基于 `String` 的扩展操作，并且对于很多常见类型都提供了丰富的重载来优化性能。

其中最重要的是 `ConsoleReader` 和 `ConsoleWriter` 类型提供了并发安全的保证，可以在任意线程中安全地通过该类型提供的接口来读写内容。

`getStdIn()` 返回用于读取当前进程标准输入的 `ConsoleReader`。数据来源由进程的标准输入配置决定：连接终端时通常为键盘输入；重定向时可以为文件内容或其他进程通过管道写入的数据。该函数不负责选择输入文件或建立网络连接。

当需要从标准输入流中获取数据时，可以通过 `getStdIn` 全局函数获取 `ConsoleReader` 类型，再通过该类型的 `readln` 函数获取命令行的输入。

标准输入流读取示例：

<!-- compile -->

```cangjie
import std.env.getStdIn

main() {
    let consoleReader = getStdIn()
    let txt = consoleReader.readln()
    println(txt ?? "")
}
```

运行上面的代码，在命令行上输入一些文字，然后换行结束，即可看到输入的内容。

`ConsoleReader.read(buffer)` 优先使用缓存数据；缓存不足时，通过行读取路径继续补充，直到目标数组填满、输入结束或读取失败。换行仅结束一次行读取，不一定使本次 `read` 返回。例如，目标数组长度为 8 时，输入 `abc\n` 后仍可能等待下一行；输入 8 个字节但未包含换行时，也可能等待行读取完成。输入结束或读取失败时，返回的有效字节数可以小于数组长度；目标数组为空时返回 `0`。调用方应按返回计数处理数据。该方法不适用于写端发送部分数据后等待响应的管道交互。

`readSome(buffer)` 提供短读接口，返回实际读取的字节数 `n`，有效数据位于 `buffer` 的前 `n` 个字节。返回计数由目标数组容量和本次取得的数据共同决定：

- `ConsoleReader` 实例缓存非空时，复制有效数据并返回缓存剩余字节数与数组容量中的较小值，不为填满数组追加读取。
- 对于重定向文件或管道，实例缓存为空时优先读取原生共享缓存；该缓存也为空时，返回平台读取操作（POSIX `read` 或 Windows `ReadFile`）实际取得的字节数。取得数据后返回，不为填满数组继续读取，也不以换行或写端关闭为返回条件。
- 交互终端输入受终端模式约束；Windows 字符设备使用行读取路径。终端可能在收到换行后才提供数据，因此短读接口不保证逐键返回或非阻塞读取。

单次读取不保证取得当前所有可用数据，读取边界也不保证与单次写入、网络数据包或协议消息的边界一致。一次写入的数据可能分多次读取，多次写入的数据也可能在一次读取中返回。没有数据可读且未到达流末尾时，调用仍可能阻塞。

Windows 重定向输入中，行读取路径采用文本语义：CRLF 转为 LF，`Ctrl+Z`（`0x1A`）作为 EOF。仅使用 `readSome` 时，输入按原始字节读取；若 `read`、`readln` 或 `readUntil` 已将数据预取到 `ConsoleReader` 缓存，后续 `readSome` 优先返回经过文本转换的剩余数据。交替调用这些方法可以保持同一实例内的数据消费顺序，但不能恢复转换前的原始字节；需要原始字节的协议应在整个读取过程中使用 `readSome`。其他标准输入接口可能维护独立缓存，同一输入序列应统一使用 `getStdIn()` 返回的实例处理。

标准输入按字节读取示例：

<!-- compile -->

```cangjie
import std.env.getStdIn

main() {
    let consoleReader = getStdIn()
    let buffer = Array<Byte>(256, repeat: 0)
    let readSize = consoleReader.readSome(buffer)
    // 只处理本次实际读取的字节，不假定整个数组都已填满。
    println("读取到的字节数：${readSize}")
    if (readSize > 0) {
        println(buffer.slice(0, readSize))
    }
}
```

该示例输出实际读取的字节数，并在取得数据时输出有效字节数组。短读不表示输入结束，单次读取也不保证取得完整消息；调用方应按协议规定累计数据。读取边界可能位于 UTF-8 字符的多字节编码内部，因此单次读取结果不一定能够独立转换为字符串。目标数组为空、输入结束且本次未取得数据，以及部分底层读取失败时，`readSome` 均可能返回 `0`，仅凭返回值无法区分这些情况。

输出流分为标准输出流和标准错误流，默认情况下，它们都会输出到屏幕，例如在命令行界面中看到的文本。

当需要往标准输出流中写入数据时，可以通过 `getStdOut`/`getStdErr` 全局函数获取 `ConsoleWriter` 来写入，例如通过 `write` 函数来向控制台打印内容。

使用 `ConsoleWriter` 和直接使用 `print` 函数的差别是，`ConsoleWriter` 是并发安全的，并且由于 `ConsoleWriter` 使用了缓存技术，在输入内容较多时拥有更好的性能表现。

需要注意的是，写完数据后需要对 `ConsoleWriter` 调用 `flush` 才能保证内容被完整写到标准流中。

标准输出流写入示例：

<!-- run -->

```cangjie
import std.env.getStdOut

main() {
    let consoleWriter = getStdOut()
    for (_ in 0..1000) {
        consoleWriter.writeln("hello, world!")
    }
    consoleWriter.flush()
}
```

## 文件流

仓颉编程语言提供了 `fs` 包来支持通用文件系统任务。不同的操作系统对于文件系统提供的接口有所不同。仓颉编程语言抽象出以下一些共通的功能，通过统一的功能接口，屏蔽不同操作系统之间的差异，来简化使用。

常规操作任务包括：创建文件/目录、读写文件、重命名或移动文件/目录、删除文件/目录、复制文件/目录、获取文件/目录元数据、检查文件/目录是否存在。具体 API 可以查阅库文档。

使用文件系统相关的功能需要导入 `fs` 包：

导入 fs 包示例：

<!-- run -->

```cangjie
import std.fs.*
```

本章会着重介绍 `File` 相关的使用，对于 `Path` 和 `Directory` 的使用可以查阅对应的 API 文档。

`File` 类型在仓颉编程语言中同时提供了常规文件操作和文件流两类功能。

### 常规文件操作

对于常规的文件操作，可以使用一系列静态函数来完成快捷的操作。

例如如果要检查某个路径对应的文件是否存在，可以使用 `exists` 函数。当 `exists` 函数返回 `true` 时表示文件存在，反之不存在。

exists 函数使用示例：

<!-- run -->

```cangjie
import std.fs.exists

main() {
    let exist = exists("./tempFile.txt")
    println("exist: ${exist}")
}
```

移动文件、拷贝文件和删除文件也非常简单，`File` 同样提供了对应的静态函数 `move`、`copy`、`delete`。

move、copy、delete 函数使用示例：

<!-- compile -->

```cangjie
import std.fs.{copy, rename, remove}

main() {
    copy("./tempFile.txt", to: "./tempFile2.txt", overwrite: false)
    rename("./tempFile2.txt", to: "./tempFile3.txt", overwrite: false)
    remove("./tempFile3.txt")
}
```

如果需要直接将文件的所有数据读出来，或者一次性将数据写入文件里，可以使用 `File` 提供的 `readFrom`、`writeTo` 函数直接读写文件。在数据量较少的情况下它们既简单易用又能提供较好的性能表现，无需手动处理数据流。

readFrom、writeTo 函数使用示例：

<!-- compile -->

```cangjie
import std.fs.File

main() {
    let bytes = File.readFrom("./tempFile.txt") // 一次性读取了所有的数据
    File.writeTo("./otherFile.txt", bytes) // 把数据一次性写入另一个文件中
}
```

### 文件流操作

除了上述的常规文件操作之外，`File` 类型也被设计为一种数据流类型，因此 `File` 类型本身实现了 `IOStream` 接口。当创建了一个 `File` 的实例，可以把这个实例当成数据流来使用。

`File` 提供了两种构造方式，一种是通过方便的静态函数 `create` 直接创建新文件的实例，另一种是通过构造函数传入完整的打开文件模式来构造新实例。

其中 `create` 创建的文件是只写的，不能对实例进行读操作，否则会抛出运行时异常。

File 构造示例：

<!-- compile -->

```cangjie
// 创建
internal import std.fs.*
internal import std.io.*

main() {
    let file = File.create("./tempFile.txt")
    file.write("hello, world!".toArray())

    // 打开
    let file2 = File("./tempFile.txt", Read)
    let bytes = readToEnd(file2) // 读取所有数据
    println(bytes)
}
```

当需要更精细的打开模式时，可以使用构造函数传入一个 `OpenMode` 值。`OpenMode` 是一个 `enum` 类型，它提供了丰富的文件打开模式，包含 `Read`、`Write`、`Append` 和 `ReadWrite` 模式。

File 打开模式使用示例：

<!-- run -->

```cangjie
// 使用指定选项打开模式
let file = File("./tempFile.txt", Write)
```

因为打开 `File` 的实例会占用宝贵的系统资源，所以使用完 `File` 的实例之后需要注意及时关闭 `File`，以释放系统资源。

`File` 实现了 `Resource` 接口，在大多数时候都可以使用 try-with-resource 语法来简化使用。

try-with-resource 语法使用示例：

<!-- run -->

```cangjie
try (file2 = File("./tempFile.txt", Read)) {
    // ...
    // 结束使用后自动释放文件
}
```
