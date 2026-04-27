if (let Some(a) <- b || a > 1) {} // Conditions connected by `||` cannot use enum patterns that bind variables
if (let Some(a) <- b && a + 1) {} // Right side of `&&` is neither a let pattern nor a Boolean-type expression
if (a > 3 && let Some(a) <- b) {} // a is bound by Some(a) pattern; cannot use it on the left side of the binding pattern
if (let Some(a) <- b && a > 3) {
    println("${a} > 3")
} else {
    println("${a} < 3") // a can only be used in the if branch, not the else branch
}
if (let Some(a) <- b where a > 3) {} // Use `&&` for condition checks, not `where`