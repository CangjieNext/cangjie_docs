import stdx.net.http.*
import stdx.encoding.url.*
import std.time.*
import std.sync.*
import std.collection.*
import stdx.log.*

let server = ServerBuilder().addr("127.0.0.1").port(0).build()

// Client:
main() {
    // 1 Start the server
    spawn {startServer()}
    sleep(Duration.millisecond * 200)

    let client = ClientBuilder().build()
    let u = URL.parse("ws://127.0.0.1:${server.port}/webSocket")

    let subProtocol = ArrayList<String>(["foo1", "bar1"])
    let headers = HttpHeaders()
    headers.add("test", "echo")

    // 2 Complete WebSocket handshake and obtain WebSocket instance
    let websocket: WebSocket
    let respHeaders: HttpHeaders
    (websocket, respHeaders) = WebSocket.upgradeFromClient(client, u, subProtocols: subProtocol, headers: headers)
    client.close()

    println("subProtocol: ${websocket.subProtocol}") // fool1
    println(respHeaders.getFirst("rsp") ?? "") // echo

    // 3 Message exchange
    // Send "hello"
    websocket.write(TextWebFrame, "hello".toArray())
    // Receive
    let data = ArrayList<UInt8>()
    var frame = websocket.read()
    while (true) {
        match (frame.frameType) {
            case ContinuationWebFrame =>
                data.add(all: frame.payload)
                if (frame.fin) {
                    break
                }
            case TextWebFrame | BinaryWebFrame =>
                if (!data.isEmpty()) {
                    throw Exception("invalid frame")
                }
                data.add(all: frame.payload)
                if (frame.fin) {
                    break
                }
            case CloseWebFrame =>
                websocket.write(CloseWebFrame, frame.payload)
                break
            case PingWebFrame => websocket.writePongFrame(frame.payload)
            case _ => ()
        }
        frame = websocket.read()
    }
    println("data size: ${data.size}") // 4097
    println("last item: ${String.fromUtf8(data.toArray()[4096])}") // a

    // 4 Close WebSocket
    // Exchange CloseFrame
    websocket.writeCloseFrame(status: 1000)
    let websocketFrame = websocket.read()
    println("close frame type: ${websocketFrame.frameType}") // CloseWebFrame
    println("close frame payload: ${websocketFrame.payload}") // 3, 232

    // Close underlying connection
    websocket.closeConn()

    server.close()
}

func startServer() {
    // 1 Register handler
    server.distributor.register("/webSocket", handler1)
    server.logger.level = LogLevel.OFF
    server.serve()
}

// Server:
func handler1(ctx: HttpContext): Unit {
    // 2 Complete WebSocket handshake and obtain WebSocket instance
    let websocketServer = WebSocket.upgradeFromServer(
        ctx,
        subProtocols: ArrayList<String>(["foo", "bar", "foo1"]),
        userFunc: {
            request: HttpRequest =>
                let value = request.headers.getFirst("test") ?? ""
                let headers = HttpHeaders()
                headers.add("rsp", value)
                headers
        }
    )
    // 3 Message exchange
    // Receive "hello"
    let data = ArrayList<UInt8>()
    var frame = websocketServer.read()
    while (true) {
        match (frame.frameType) {
            case ContinuationWebFrame =>
                data.add(all: frame.payload)
                if (frame.fin) {
                    break
                }
            case TextWebFrame | BinaryWebFrame =>
                if (!data.isEmpty()) {
                    throw Exception("invalid frame")
                }
                data.add(all: frame.payload)
                if (frame.fin) {
                    break
                }
            case CloseWebFrame =>
                websocketServer.write(CloseWebFrame, frame.payload)
                break
            case PingWebFrame => websocketServer.writePongFrame(frame.payload)
            case _ => ()
        }
        frame = websocketServer.read()
    }
    println("data: ${String.fromUtf8(data.toArray())}") // hello

    // Send 4097 'a's
    websocketServer.write(TextWebFrame, Array<UInt8>(4097, repeat: 97))

    // 4 Close WebSocket
    // Exchange CloseFrame
    let websocketFrame = websocketServer.read()
    println("close frame type: ${websocketFrame.frameType}") // CloseWebFrame
    println("close frame payload: ${websocketFrame.payload}") // 3, 232
    websocketServer.write(CloseWebFrame, websocketFrame.payload)
    // Close underlying connection
    websocketServer.closeConn()
}
