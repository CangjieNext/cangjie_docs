public enum Peano {
    | Z
    | S(Peano)

    public func toInt(): Int {
        match (this) {
            case Z => 0
            case S(x) => 1 + x.toInt()
        }
    }
}