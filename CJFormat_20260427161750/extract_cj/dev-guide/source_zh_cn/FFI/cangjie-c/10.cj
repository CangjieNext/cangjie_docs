foreign func getCount(): Int64
// Cangjie invokes the preceding C language logic
spawn {
    let r1 = unsafe { getCount() }  // r1 equals 1
    sleep(Duration.second * 10)
    let r2 = unsafe { getCount() }  // r2 may not be equal to 2
}