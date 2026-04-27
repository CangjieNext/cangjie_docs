@Annotation[target: [MemberFunction]]
public class Marked {
    const init() {}
}

class A {
    @Marked // OK, member funciton
    func marked() {}
}

@Marked // Error, type
class B {}