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

默认情况下标准输入流来源于键盘输入的信息，例如在命令行界面中输入的文本。

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

`ConsoleReader.read(buffer)` 保留原有的按行取数、尝试填满数组的行为；遇到输入结束或读取失败时，仍可能返回不足数组长度的数据。调用方应根据返回计数处理有效前缀。该方法可能等待换行，因此不适合写端发送部分数据后等待响应的管道交互。

需要按可用数据分块处理标准输入时，可以调用 `readSome(buffer)`。单次调用允许短读：内部缓存已有数据时返回缓存中的有效前缀，否则尝试读取输入；重定向管道读取不要求换行，也不等待数组填满或写端关闭。没有数据可读且未到达流末尾时，读取仍可能阻塞等待；交互终端仍受行缓冲等设置影响。允许短读不等于非阻塞读取。

Windows 重定向输入中，旧的行读取路径保留默认文本语义：CRLF 转为 LF，`Ctrl+Z`（`0x1A`）作为 EOF。独立使用 `readSome` 时，按原始字节读取；若先调用 `read`、`readln` 或 `readUntil` 将数据预取到 `ConsoleReader` 缓存，后续 `readSome` 会先返回已经过文本转换的剩余数据。混用这些方法保持该实例内的消费顺序，但不保证还原输入的原始字节；依赖原始字节的协议应从开始就使用 `readSome` 或基于它的 `readFully`。

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

上面的示例输出实际读取的字节数，并在读到数据时输出对应的字节数组。短读不表示输入结束，一次读取也不对应一条完整消息；继续读取时应根据协议累计数据。按字节分块还可能截断 UTF-8 字符，不应假定每块数据都能独立转换为字符串。`readSome` 保留了部分底层读取失败也返回 `0` 的行为，因此不能用 `0` 区分所有读取错误与正常 EOF。若需要严格读满数组，可以使用下面的 `ConsoleReader.readFully`。

### 读取固定长度的数据

当协议要求从标准输入取得固定长度的数据时，可以使用 `ConsoleReader.readFully`。它循环调用 `readSome`，将后续数据读入数组中尚未填充的部分。例如，下面的程序读取 8 字节协议头：

<!-- compile -->

```cangjie
import std.env.getStdIn
import std.io.IOException

main() {
    let header = Array<Byte>(8, repeat: 0)
    try {
        getStdIn().readFully(header)
        println(header)
    } catch (e: IOException) {
        println("协议头读取失败：${e.message}")
    }
}
```

将包含 `abcdefgh` 的文件重定向为标准输入时，输出为：

```text
[97, 98, 99, 100, 101, 102, 103, 104]
```

若管道只发送 `abc` 且写端保持打开，程序会继续等待后续 5 字节；收到后立即完成，不等待写端关闭。若提前结束则抛出 `IOException`，目标数组可能已部分修改，不能将其作为完整协议头处理。

`readFully` 不关闭输入流，不识别消息边界，也不提供超时或取消；多次读取不保证整体互斥，调用方应根据协议确定目标长度，并协调同一流上的其他消费者。空目标数组直接成功。标准输入现有实现还可能将底层读取失败映射为 `0`；此时 `readFully` 报告未填满，无法恢复原始错误原因。

其他 `InputStream` 实现可以使用 `std.io` 包中的顶层函数 `readFully(input, buffer)`，其成功条件同样是填满目标数组。例如：

<!-- run -->

```cangjie
import std.io.{ByteBuffer, readFully}

main() {
    let input = ByteBuffer("abcdefgh".toArray())
    let header = Array<Byte>(8, repeat: 0)
    readFully(input, header)
    println(header)
}
```

顶层函数循环调用 `input.read`，继承该方法原有的等待方式。将 `ConsoleReader` 作为 `InputStream` 传给顶层函数时，调用的仍是旧 `read` 路径，可能等待换行；这与直接调用 `getStdIn().readFully(buffer)` 的短读路径不同。`InputStream` 接口本身不提供 `readFully` 成员。

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
