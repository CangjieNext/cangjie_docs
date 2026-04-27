public macro Component(input: Tokens): Tokens {
    var varDecl = parseDecl(input)
    if (varDecl.hasAttr("State")) { // Returns true if the node is marked with the "State" attribute, otherwise false
        var attrs = varDecl.getAttrs() // Returns a set of Tokens
        println(attrs[0].value)
    }
    return input
}