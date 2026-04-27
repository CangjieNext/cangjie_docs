public enum Colors <: ToString & Equatable < Colors > {
    | Red
    | Green
    | Blue

    func get(): String {
        match(this) {
            case Red => "RED"
            case Green => "GREEN"
            case Blue => "BLUE"
        }
    }

    static func parse(val: String): Colors {
        match(val) {
            case "RED" => Red
            case "GREEN" => Green
            case "BLUE" => Blue
            case _ => throw IllegalArgumentException("unknown value ${val}")
        }
    }

    static func tryParse(val: ?String): ?Colors {
        match(val) {
            case Some(v) => parse(v)
            case None => None
        }
    }

    public func toString(): String {
        get()
    }

    public override operator func ==(that: Colors): Bool {
        match((this, that)) {
            case(Red, Red) => true
            case(Green, Green) => true
            case(Blue, Blue) => true
            case _ => false
        }
    }

    public override operator func !=(that: Colors): Bool {
        !(this == that)
    }
}