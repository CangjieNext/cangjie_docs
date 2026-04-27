struct Foo {
    var i = 0

    public mut func f(): Foo {
        let f1 = { => this } // Error, 'this' in mut functions cannot be captured
        let f2 = { => this.i = 2 } // Error, instance member variables in mut functions cannot be captured
        let f3 = { => this.i } // Error, instance member variables in mut functions cannot be captured
        let f4 = { => i } // Error, instance member variables in mut functions cannot be captured
        this // Error, 'this' in mut functions cannot be used as expressions
    }
}