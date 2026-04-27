while (true) {
    func f() {
        break // Error, break must be used directly inside a loop
    }
    let g = { =>
        continue // Error, continue must be used directly inside a loop
    }
}