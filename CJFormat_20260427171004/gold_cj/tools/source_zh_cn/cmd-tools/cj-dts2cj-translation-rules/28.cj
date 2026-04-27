public enum Status <: ToString & Equatable<Status> {
    | Pending
    | Approved
    | Rejected

    func get(): Int32 {
        match (this) {
            case Pending => 3
            case Approved => 4
            case Rejected => 5
        }
    }

    static func parse(val: Int32): Status {
        match (val) {
            case 3 => Pending
            case 4 => Approved
            case 5 => Rejected
            case _ => throw IllegalArgumentException("unknown value ${val}")
        }
    }

    static func tryParse(val: ?Int32): ?Status {
        match (val) {
            case Some(v) => parse(v)
            case None => None
        }
    }

    public func toString(): String {
        match (this) {
            case Pending => "Pending"
            case Approved => "Approved"
            case Rejected => "Rejected"
        }
    }

    public override operator func ==(that: Status): Bool {
        match ((this, that)) {
            case (Pending, Pending) => true
            case (Approved, Approved) => true
            case (Rejected, Rejected) => true
            case _ => false
        }
    }

    public override operator func !=(that: Status): Bool {
        !(this == that)
    }
}
