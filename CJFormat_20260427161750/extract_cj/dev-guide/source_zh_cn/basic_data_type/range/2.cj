let n = 10
let r1 = 0..10 : 1   // r1 contains 0, 1, 2, 3, 4, 5, 6, 7, 8, 9
let r2 = 0..=n : 1   // r2 contains 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
let r3 = n..0 : -2   // r3 contains 10, 8, 6, 4, 2
let r4 = 10..=0 : -2 // r4 contains 10, 8, 6, 4, 2, 0