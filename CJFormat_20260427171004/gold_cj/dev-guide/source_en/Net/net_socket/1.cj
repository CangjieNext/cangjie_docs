import std.time.*
import std.sync.*
import std.net.*

var SERVER_PORT: UInt16 = 0

func runTcpServer() {
    try (serverSocket = TcpServerSocket(bindAt: SERVER_PORT)) {
        serverSocket.bind()
        SERVER_PORT = (serverSocket.localAddress as IPSocketAddress)?.port ?? 0

        try (client = serverSocket.accept()) {
            let buf = Array<Byte>(10, repeat: 0)
            let count = client.read(buf)

            // Data read by server: [1, 2, 3, 0, 0, 0, 0, 0, 0, 0]
            println("Server read ${count} bytes: ${buf}")
        }
    }
}

main(): Int64 {
    let future = spawn {
        runTcpServer()
    }
    sleep(Duration.millisecond * 500)

    try (socket = TcpSocket("127.0.0.1", SERVER_PORT)) {
        socket.connect()
        socket.write([1, 2, 3])
    }

    future.get()

    return 0
}
