public class TypeInfo {
    public static func of(a: Any): TypeInfo
    public static func of(a: Object): ClassTypeInfo
    public static func of<T>(): TypeInfo
}
