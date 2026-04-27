class MyApp <: App {
    let album = albumCreate()
    let page: Router
    // Blank line
    // Blank line
    // Blank line
    init() { // Incorrect: Consecutive blank lines in type
        this.page = Router("album", album)
    }

    override func onCreate(): Unit {
        println("album Init.") // Incorrect: Blank lines inside braces

    }
}
