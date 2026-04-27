main() {
    type I64 = Int64 // Error, type aliases can only be defined at the top level of the source file
}

class LongNameClassA { }
type B = LongNameClassB // Error, type 'LongNameClassB' is not defined