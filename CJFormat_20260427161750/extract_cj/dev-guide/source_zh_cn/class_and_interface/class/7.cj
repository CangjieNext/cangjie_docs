class Rectangle {
    let width: Int64
    let height: Int64

    public init(width: Int64, height: Int64) { // Error, 'height' is not initialized in the constructor
        this.width = width
    }
}