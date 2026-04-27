// common file
package cmp

common enum A { ELEMENT1 | ELEMENT2 }
common enum B { ELEMENT1 | ELEMENT2 }
common enum C { ELEMENT1 | ELEMENT2 }
common enum D { ELEMENT1 | ELEMENT2 | ... }
common enum E { ELEMENT1 | ELEMENT2 | ... }

// specific file
package cmp

specific enum A { ELEMENT1 | ELEMENT2 }                   // ok
specific enum B { ELEMENT1 | ELEMENT2 | ELEMENT3 }        // error: exhaustive enum cannot add new constructor
specific enum C { ELEMENT1 | ELEMENT2 | ... }             // error: exhaustive 'common' enum cannot be matched with non-exhaustive 'specific' enum
specific enum D { ELEMENT1 | ELEMENT2 | ELEMENT3 }        // ok
specific enum E { ELEMENT1 | ELEMENT2 | ELEMENT3 | ... }  // ok