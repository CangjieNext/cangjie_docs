enum E {
    Ctor(Int64, String) | Ctor
}

main() {
    var temp = E.Ctor(10, "String")
    0
}

========================================
(cjdb) p temp
(E) $0 = Ctor {
  arg_1 = 10
  arg_2 = "String"
}