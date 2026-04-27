// Scenario 4

class C {
    C(var a!: Int64, var b!: Float64) {
        this.a = a
        this.b = b
    }

    public init(a: Int64) {
        b = 0.0
        this.a = a
    }
}
