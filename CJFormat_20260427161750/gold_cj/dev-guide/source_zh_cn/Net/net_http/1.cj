import stdx.net.http.*
import std.time.*
import std.sync.*
import stdx.log.*

// 1. 构建 Server 实例
let server = ServerBuilder().addr("127.0.0.1").port(0).build()

func startServer(): Unit {
    // 2. 注册请求处理逻辑
    server.distributor.register("/hello", {
        httpContext => httpContext.responseBuilder.body("Hello Cangjie!")
    })
    server.logger.level = LogLevel.OFF
    // 3. 启动服务
    server.serve()
}

func startClient(): Unit {
    // 1. 构建 client 实例
    let client = ClientBuilder().build()
    // 2. 发送 request
    let response = client.get("http://127.0.0.1:${server.port}/hello")
    // 3. 读取response body
    let buffer = Array<Byte>(32, repeat: 0)
    let length = response.body.read(buffer)
    println(String.fromUtf8(buffer[..length]))
    // 4. 关闭连接
    client.close()
}

main() {
    spawn {
        startServer()
    }
    sleep(Duration.second)
    startClient()
}
