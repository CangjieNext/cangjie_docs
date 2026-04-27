public class ThreadLocal<T> {
    /* 构造一个携带空值的仓颉线程局部变量 */
    public init()

    /* 获得仓颉线程局部变量的值 */
    public func get(): Option<T> // 如果值不存在，则返回 Option<T>.None。返回值 Option<T> - 仓颉线程局部变量的值

    /* 通过 value 设置仓颉线程局部变量的值 */
    public func set(value: Option<T>): Unit // 如果传入 Option<T>.None，该局部变量的值将被删除，在线程后续操作中将无法获取。参数 value - 需要设置的局部变量的值。
}