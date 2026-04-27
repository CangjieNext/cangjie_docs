let r5 = 0..10 // the step of r5 is 1, and r5 contains 0, 1, 2, 3, 4, 5, 6, 7, 8, 9
let r6 = 0..10 : 0 // Error, step cannot be 0

let r7 = 10..0 : 1 // r7 to r10 are empty ranges
let r8 = 0..10 : -1
let r9 = 10..=0 : 1
let r10 = 0..=10 : -1
