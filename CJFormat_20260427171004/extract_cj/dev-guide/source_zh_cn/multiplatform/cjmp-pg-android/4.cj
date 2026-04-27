@JavaImpl
class NamedNode <: Node {
    public var jName: JString  /* 该实例成员变量保存在互操作类的共轭 Java 包装类实例中 */
    public var cjName: String  /* 该实例成员变量保存在互操作类实例中 */
    init(name: JString) {
        jName = name
        cjName = name.toCangjieString()
    }
}