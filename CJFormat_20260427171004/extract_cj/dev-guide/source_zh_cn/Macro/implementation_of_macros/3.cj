@MacroName func name() {}        // Before a FuncDecl
@MacroName struct name {}        // Before a StructDecl
@MacroName class name {}         // Before a ClassDecl
@MacroName var a = 1             // Before a VarDecl
@MacroName enum e {}             // Before a Enum
@MacroName interface i {}        // Before a InterfaceDecl
@MacroName extend e <: i {}      // Before a ExtendDecl
class C {
    @MacroName prop i: Int64 {   // Before a PropDecl
        get() { 0 }
    }
} 
@MacroName @AnotherMacro(input)  // Before a macro call