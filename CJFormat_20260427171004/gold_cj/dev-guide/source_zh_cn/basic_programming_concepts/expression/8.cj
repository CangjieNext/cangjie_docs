if (let Some(a) <- fun() as Option<Int64>) {}   // 解析错误，`as` 的优先级低于  `..`
if (let Some(a) <- (fun() as Option<Int64>)) {} // 正确
if (let Some(a) <- b && a + b > 3) {}           // 正确，解析为 (let Some(a) <- b) && (a + b > 3)
if (let m <- 0..generateSomeInt()) {}           // 正确