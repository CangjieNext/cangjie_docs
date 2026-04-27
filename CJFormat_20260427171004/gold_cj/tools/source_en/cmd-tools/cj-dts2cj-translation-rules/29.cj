public enum Response <: ToString & Equatable<Response> {
    | No
    | Yes

    func get(): String {
        match (this) {
            case No => "0"
            case Yes => "YES"
        }
    }

    static func parse(val: String): Response {
        match (val) {
            case "0" => No
            case "YES" => Yes
            case _ => throw IllegalArgumentException("unknown value ${val}")
        }
    }

    static func tryParse(val: ?String): ?Response {
        match (val) {
            case Some(v) => parse(v)
            case None => None
        }
    }

    public func toString(): String {
        get()
    }

    public override operator func ==(that: Response): Bool {
        match ((this, that)) {
            case (No, No) => true
            case (Yes, Yes) => true
            case _ => false
        }
    }

    public override operator func !=(that: Response): Bool {
        !(this == that)
    }
}
