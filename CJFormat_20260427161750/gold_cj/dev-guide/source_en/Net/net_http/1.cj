import stdx.net.http.*
import std.time.*
import std.sync.*
import stdx.log.*

// 1. Build a Server instance
let server = ServerBuilder().addr("127.0.0.1").port(0).build()

func startServer(): Unit {
    // 2. Register request handling logic
    server.distributor.register("/hello", {
        httpContext => httpContext.responseBuilder.body("Hello Cangjie!")
    })
    server.logger.level = LogLevel.OFF
    // 3. Start the service
    server.serve()
}

func startClient(): Unit {
    // 1. Build a client instance
    let client = ClientBuilder().build()
    // 2. Send a request
    let response = client.get("http://127.0.0.1:${server.port}/hello")
    // 3. Read the response body
    let buffer = Array<Byte>(32, repeat: 0)
    let length = response.body.read(buffer)
    println(String.fromUtf8(buffer[..length]))
    // 4. Close the connection
    client.close()
}

main() {
    spawn {
        startServer()
    }
    sleep(Duration.second)
    startClient()
}
