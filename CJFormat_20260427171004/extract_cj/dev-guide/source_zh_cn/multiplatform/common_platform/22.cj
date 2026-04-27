// common part
public common abstract class A {
    init() {}
    public common func a(): Int{1}
    public open func b(): Int{2}
    public common open func c(): Int {3}
    public common func d(): Int
    public common abstract func e(): Int
    public common abstract func f(): Int
    public abstract func g(): Int

    public common open prop prop_a: Int{ get() { 1 } }
    public common prop prop_b: Int { get() { 1 } }
    public abstract prop prop_c: Int
}

public class B <: A {
  public func b(): Int { a() + 10 }
  public func c(): Int { a() + 20 }
  public func e(): Int { a() + 30 }
  public func f(): Int { a() + 40 }
  public func g(): Int { a() + 50 }

  public prop prop_c: Int { get() { 10 } }
}