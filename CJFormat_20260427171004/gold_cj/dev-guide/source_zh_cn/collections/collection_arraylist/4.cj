let a = ArrayList<String>() // Created an empty ArrayList whose element type is String
let b = ArrayList<String>(100) // Created an ArrayList whose element type is String, and allocate a space of 100
let c = ArrayList<Int64>([0, 1, 2]) // Created an ArrayList whose element type is Int64, containing elements 0, 1, 2
let d = ArrayList<Int64>(c) // Use another Collection to initialize an ArrayList
let e = ArrayList<String>(2, {x: Int64 => x.toString()}) // Created an ArrayList whose element type is String and size is 2. All elements are initialized by specified rule function
