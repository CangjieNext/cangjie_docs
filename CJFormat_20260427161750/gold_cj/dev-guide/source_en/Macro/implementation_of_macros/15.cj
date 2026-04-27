import define.Foo

// attribute macro with parentheses
var a: Int64 = @Foo[1+](2+3)

// attribute macro without parentheses
@Foo[public]
struct Data {
    var count: Int64 = 100
}

main() {}
