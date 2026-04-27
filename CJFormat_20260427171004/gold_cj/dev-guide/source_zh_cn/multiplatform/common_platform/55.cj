// specific file
specific extend Int32 {} // ok

specific extend Int64 {}

specific extend Int64 {} // error: direct extension of Int64 redefinition

interface B {}

specific extend A <: I {} // ok

specific extend C <: B {} // error: the interfaces of specific extend do not match those on common extend
