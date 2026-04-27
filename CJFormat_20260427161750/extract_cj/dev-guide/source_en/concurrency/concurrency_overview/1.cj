foreign socket_read(sock: Int64): CPointer<Int8>

let fut = spawn {
    let sock: Int64 = ...
    let ptr = socket_read(sock)
}