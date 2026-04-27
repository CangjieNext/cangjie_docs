var isTrue: Bool = (1, 3) == (0, 2) // false
isTrue = (1, "123") == (1.0, 2)      // Compilation error: the types of the two operands are inconsistent
isTrue = (1, _) == (1.0, _)          // Compilation error: wildcards cannot be used as tuple elements for matching