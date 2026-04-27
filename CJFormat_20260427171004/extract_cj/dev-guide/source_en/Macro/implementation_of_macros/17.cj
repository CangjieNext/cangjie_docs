// Illegal attribute Tokens
@MacroName[#]()    // Not a whole Token
@MacroName[`]()    // Not a whole Token
@MacroName[@]()    // Not escape for @
@MacroName[[]()    // [ and ] not match
@MacroName[\(]()   // Escape for unsupported symbol

// Legal attribute Tokens
@MacroName[#"abc"#]()
@MacroName[`class`]()
@MacroName[(]()
@MacroName[()]()
@MacroName[\[]()
@MacroName[\@]()