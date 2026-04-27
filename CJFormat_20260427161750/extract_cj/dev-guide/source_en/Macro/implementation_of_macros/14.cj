macro package define

// Macro definition with attribute
public macro Foo(attrTokens: Tokens, inputTokens: Tokens): Tokens {
    return attrTokens + inputTokens  // Concatenate attrTokens and inputTokens.
}