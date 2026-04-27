macro package define

public macro Component(input: Tokens): Tokens {
    var varDecl = parseDecl(input)
    if (varDecl.hasAttr("State")) { // 如果该节点被标记了属性且值为 "State"，则返回 true，否则返回 false
        var attrs = varDecl.getAttrs() // 返回一组 Tokens
        println(attrs[0].value)
    }
    return input
}