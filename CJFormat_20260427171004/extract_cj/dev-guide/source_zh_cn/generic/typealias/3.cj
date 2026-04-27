type A = (Int64, A) // Error, 'A' refered itself
type B = (Int64, C) // Error, 'B' and 'C' are circularly refered
type C = (B, Int64)