package macro_calling

import macro_definition.*

var counter = 0

@ModifyFunc
func myFunc() {
    counter++
}

func exModifyFunc() {
    println("I'm in function body")
    myFunc(123)
    println("myFunc called: ${counter} times")
    return 0
}

main(): Int64 {
    exModifyFunc()
}