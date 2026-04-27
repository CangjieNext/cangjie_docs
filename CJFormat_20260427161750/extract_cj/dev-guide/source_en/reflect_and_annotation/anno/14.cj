@Annotation[target: [MemberFunction]]
public class Marked {
    const init() {}
}

class A {
    @Marked // OK, member function
    func marked() {}
}

@Marked // Error, type
class B {}