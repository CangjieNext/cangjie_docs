var display = { => println("Hello") }

func f2(lam: () -> Unit) {}
let f2Res = f2 { println("World") } // OK to omit the =>