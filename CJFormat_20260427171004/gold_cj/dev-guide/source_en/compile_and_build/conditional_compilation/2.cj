@When[os == "Windows"]
@When[os == "Linux"]    // Error, illegal nested when conditional compilation
import std.ast.*
@When[os == "Windows"]
@When[os == "Linux"]    // Error, illegal nested when conditional compilation
func A(){}