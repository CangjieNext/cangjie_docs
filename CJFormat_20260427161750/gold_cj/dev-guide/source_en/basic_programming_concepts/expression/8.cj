if (let Some(a) <- fun() as Option<Int64>) {}   // Parsing error: `as` has lower precedence than `..`
if (let Some(a) <- (fun() as Option<Int64>)) {} // Correct
if (let Some(a) <- b && a + b > 3) {}           // Correct, parsed as (let Some(a) <- b) && (a + b > 3)
if (let m <- 0..generateSomeInt()) {}           // Correct