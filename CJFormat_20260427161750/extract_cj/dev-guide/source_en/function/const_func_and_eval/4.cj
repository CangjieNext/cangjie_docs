open public class Boo {
    let boo: String
    const init(b: String) {
        this.boo = b
    }
}

public class Foo <: Boo {
    let c: String
    const init(c: String) { //Error, there is no non-parameter constructor in super class, please invoke super call explicitly
        this.c = c
    }
}