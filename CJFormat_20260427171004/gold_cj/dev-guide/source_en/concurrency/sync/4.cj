var obj: AtomicInt32 = AtomicInt32(1)
var x = obj.load() // x: 1, the type is Int32
x = obj.swap(2) // x: 1
x = obj.load() // x: 2
var y = obj.compareAndSwap(2, 3) // y: true, the type is Bool.
y = obj.compareAndSwap(2, 3) // y: false, the value in obj is no longer 2 but 3. Therefore, the CAS operation fails.
x = obj.fetchAdd(1) // x: 3
x = obj.load() // x: 4