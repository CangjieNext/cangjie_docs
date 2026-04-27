package a

private func f1() { 1 }   // f1 is visible only within the current file
func f2() { 2 }           // f2 is visible only within the current package and subpackages
protected func f3() { 3 } // f3 is visible only within the current module
public func f4() { 4 }    // f4 is visible both inside and outside the module