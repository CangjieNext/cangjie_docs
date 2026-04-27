func safeDiv(a: Int64, b: Int64): Option<Int64> {
    var res: Option<Int64> = match (b) {
        case 0 => None
        case _ => Some(a / b)
    }
    return res
}
