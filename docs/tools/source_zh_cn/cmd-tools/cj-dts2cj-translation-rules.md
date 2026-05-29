# ArkTS 三方模块生成仓颉胶水代码的转换规则

## 顶层声明

| .d.ts    | 支持范围                                                     | 规格约束                                                     |
| -------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| 命名空间 | 无                                                           | 不支持                                                     |
| 全局函数 | 支持重载，支持泛型函数                                                     | |
| 全局变量 | 需要用户手动修改成正确的初始化值                             | 不支持泛型类型全局变量                                       |
| 接口     | 支持基本类型接口、可选属性、只读属性、成员函数、泛型、函数重载、数组类型、继承、嵌套对象 | 不支持索引签名、动态属性、函数类型、构造函数、声明合并 |
| 类型别名 | 支持枚举类型别名、class 类型别名、函数类型别名、联合类型别名  | 不支持对象字面量类型别名、命名空间中的类型的类型别名、交叉类型别名、泛型类型别名 |
| 类       | 支持构造函数、静态成员、私有成员、保护成员、私有属性、泛型成员、抽象类、类实现接口、继承类、重载方法 | 不支持待装饰器类、带命名空间的类型                           |
| 枚举     | 支持字符串枚举、数字枚举、常量枚举、异构枚举                 | 不支持计算值枚举。异构枚举中，枚举值会被统一转成字符串类型，需用户在使用时手动转换 |
| 导入     | 支持                                                           |                                                        |
| 导出     | 无                                                           | 不支持                                                       |

### 命名空间

目前不支持

### 全局函数

- 支持重载。
- 参数和返回值类型支持：基础类型、函数类型、tuple 类型、optional 类型、泛型函数。
- union 类型（参数是 union 类型会映射为多个类型重载）。

示例：

.d.ts 代码：

```typescript
declare function greeter(fn: (a: string) => void): void;
declare function printToConsole(s: string): void;
```

生成的仓颉代码：

```cangjie
import ohos.ark_interop.*
import ohos.ark_interop_helper.*
import ohos.base.*

/***********METHOD***********/
/**
     * @brief greeter(fn: (a: string) => void): void
     */
public func greeter(fn: (String) -> Unit): Unit {
    hmsGlobalApiCall < Unit >( "_ark_interop_api", "greeter", { ctx =>[ctx.function({ ctx, info =>
            let p0 = String.fromJSValue(ctx, info[0])
            fn(p0)
            ctx.undefined().toJSValue()
        }).toJSValue()] })
}

/**
     * @brief printToConsole(s: string): void
     */
public func printToConsole(s: String): Unit {
    hmsGlobalApiCall < Unit >( "_ark_interop_api", "printToConsole", { ctx =>[s.toJSValue(ctx)] })
}
```

泛型函数示例：

.d.ts 代码：

```typescript
declare function testMultiGenericT<T, M>(t: T, m: M): T;
```

生成的仓颉代码：

```cangjie
import ohos.ark_interop.*
import ohos.ark_interop_helper.*
import ohos.base.*

/***********METHOD***********/
/**
     * @brief testMultiGenericT(t: T, m: M): T
     */
public func testMultiGenericT < T, M >(t: T, m: M): T where T <: JSInteropType<T>, M <: JSInteropType<M> {
    hmsGlobalApiCall < T >( "_ark_interop_api", "testMultiGenericT", { ctx =>[t.toJSValue(ctx), m.toJSValue(ctx)] }) { ctx, info => T.fromJSValue(ctx, info) }
}
```

### 全局变量

- 由于全局变量声明不带初始值，所以生成的仓颉代码需要用户补全初始化值。

示例：

.d.ts 代码：

```typescript
declare var foo: number;
declare const goo: number;
declare let qoo: number;
```

生成的仓颉代码：

```cangjie
public const foo = 0/* FIXME: Initialization is required */

public const goo = 0/* FIXME: Initialization is required */

public const qoo = 0/* FIXME: Initialization is required */
```

### 接口

- 支持基本类型、可选属性、只读属性、成员函数、泛型、函数重载、数组类型。
- 不支持索引签名、继承、动态属性、嵌套对象、函数类型、构造函数、声明合并。

#### 基本类型

.d.ts 代码：

```typescript
interface GreetingSettings {
  greeting: string;
  duration?: number;
  color?: string;
}
```

生成的仓颉代码：

```cangjie
/*interface GreetingSettings {
    greeting: String;
    duration?: number;
    color?: String;
    }*/

public open class GreetingSettings {
    public var greeting: String
    public var duration: Option<Float64> = None
    public var color: Option<String> = None
    protected init(
    greeting: String,
    duration!: Option<Float64> = None,
    color!: Option<String> = None) {
        this.greeting = greeting
        this.duration = duration
        this.color = color
    }

    public open func toJSValue(context: JSContext): JSValue {
        let obj = context.object()
        obj["greeting"] = greeting.toJSValue(context)
        if (let Some(v) <- duration) {
            obj["duration"] = v.toJSValue(context)
        }
        if (let Some(v) <- color) {
            obj["color"] = v.toJSValue(context)
        }
        obj.toJSValue()
    }

    public static func fromJSValue(context: JSContext, input: JSValue): GreetingSettings {
        let obj = input.asObject()
        GreetingSettings(
        String.fromJSValue(context, obj["greeting"]),
        duration:
        if (obj["duration"].isNull()) {
            None < Float64 >
        } else {
            Float64.fromJSValue(context, obj["duration"])
        },
        color:
        if (obj["color"].isNull()) {
            None < String >
        } else {
            String.fromJSValue(context, obj["color"])
        }
        )
    }
}
```

#### 可选属性

.d.ts 代码：

```typescript
// product.d.ts
interface Product {
  price?: number; // 可选属性
}
```

生成的仓颉代码：

```cangjie
/*interface Product {
    price?: number;
    }*/

public open class Product {
    public var price: Option<Float64> = None
    protected init(price!: Option<Float64> = None) {
        this.price = price
    }

    public open func toJSValue(context: JSContext): JSValue {
        let obj = context.object()
        if (let Some(v) <- price) {
            obj["price"] = v.toJSValue(context)
        }
        obj.toJSValue()
    }

    public static func fromJSValue(context: JSContext, input: JSValue): Product {
        let obj = input.asObject()
        Product(
        price:
        if (obj["price"].isNull()) {
            None < Float64 >
        } else {
            Float64.fromJSValue(context, obj["price"])
        }
        )
    }
}
```

#### 只读属性

.d.ts 代码：

```typescript
// point.d.ts
interface Point {
  readonly x: number;
  readonly y: number;
}
```

生成的仓颉代码：

```cangjie
/*interface Point {
    ReadonlyKeywordx: number;
    ReadonlyKeywordy: number;
    }*/

public open class Point {
    public let x: Float64
    public let y: Float64
    protected init(
    x: Float64,
    y: Float64) {
        this.x = x
        this.y = y
    }

    public open func toJSValue(context: JSContext): JSValue {
        let obj = context.object()
        obj["x"] = x.toJSValue(context)
        obj["y"] = y.toJSValue(context)
        obj.toJSValue()
    }

    public static func fromJSValue(context: JSContext, input: JSValue): Point {
        let obj = input.asObject()
        Point(
        Float64.fromJSValue(context, obj["x"]),
        Float64.fromJSValue(context, obj["y"])
        )
    }
}
```

#### 函数类型

.d.ts 代码：

```typescript
// callback.d.ts
interface Callback {
  (data: string): void;
}
```

目前还不支持

#### 成员函数

.d.ts 代码：

```typescript
// person.d.ts
interface Person {
  name: string;
  greet(): string;
}
```

生成的仓颉代码：

```cangjie
/*interface Person {
    name: String;
    greet(): String
    }*/

public open class Person {
    protected Person(var arkts_object: JSObject) { }

    public mut prop name: String {
        get() {
            checkThreadAndCall < String >(getMainContext()) {
                ctx: JSContext => String.fromJSValue(ctx, arkts_object["name"])
            }
        }
        set(v) {
            checkThreadAndCall < Unit >(getMainContext()) {
                ctx: JSContext => arkts_object["name"] = v.toJSValue(ctx)
            }
        }

    }

    /**
     * @brief greet(): String
     */
    public func greet(): String {
        jsObjApiCall < String >( arkts_object, "greet", EMPTY_ARG)
    }

    public open func toJSValue(_: JSContext): JSValue {
        arkts_object.toJSValue()
    }

    public static func fromJSValue(_: JSContext, input: JSValue): Person {
        Person(input.asObject())
    }
}
```

#### 函数重载

.d.ts 代码：

```typescript
// calculator.d.ts
interface Calculator {
  add(x: number, y: number): number;
  add(x: string, y: string): string;
}
```

生成的仓颉代码：

```cangjie
/*interface Calculator {
    add(x: number, y: number): number
    add(x: string, y: string): String
    }*/

public open class Calculator {
    protected Calculator(var arkts_object: JSObject) { }

    /**
     * @brief add(x: number, y: number): number
     */
    public func add(x: Float64, y: Float64): Float64 {
        jsObjApiCall < Float64 >( arkts_object, "add", { ctx =>[x.toJSValue(ctx), y.toJSValue(ctx)] })
    }
    /**
     * @brief add(x: string, y: string): String
     */
    public func add(x: String, y: String): String {
        jsObjApiCall < String >( arkts_object, "add", { ctx =>[x.toJSValue(ctx), y.toJSValue(ctx)] })
    }

    public open func toJSValue(_: JSContext): JSValue {
        arkts_object.toJSValue()
    }

    public static func fromJSValue(_: JSContext, input: JSValue): Calculator {
        Calculator(input.asObject())
    }
}
```

#### 数组类型

.d.ts 代码：

```typescript
// list.d.ts
interface List {
  items: string[];
  add(item: string): void;
}
```

生成的仓颉代码：

```cangjie
/*interface List {
    items: String[];
    add(item: string): void
    }*/

public open class List {
    protected List(var arkts_object: JSObject) { }

    public mut prop items: Array<String> {
        get() {
            checkThreadAndCall < Array<String> >(getMainContext()) {
                ctx: JSContext => fromJSArray < String >(ctx, arkts_object["items"])
            }
        }
        set(v) {
            checkThreadAndCall < Unit >(getMainContext()) {
                ctx: JSContext => arkts_object["items"] = toJSArray < String >(ctx, v)
            }
        }

    }

    /**
     * @brief add(item: string): void
     */
    public func add(item: String): Unit {
        jsObjApiCall < Unit >( arkts_object, "add", { ctx =>[item.toJSValue(ctx)] })
    }

    public open func toJSValue(_: JSContext): JSValue {
        arkts_object.toJSValue()
    }

    public static func fromJSValue(_: JSContext, input: JSValue): List {
        List(input.asObject())
    }
}
```

#### 继承

.d.ts 代码：

```typescript
interface A {
    p: number;
}

interface B extends A {
    p1: number
}

interface C {
    f(): void
}

interface D extends C {
}

interface E extends A {
}

interface F extends C {
    g(): void
}
```

生成的仓颉代码：

```cangjie
/*interface A {
    p: number;
    }*/

public open class A {
    public var p: Float64
    protected init(p: Float64) {
        this.p = p
    }

    public open func toJSValue(context: JSContext): JSValue {
        let obj = context.object()
        obj["p"] = p.toJSValue(context)
        obj.toJSValue()
    }

    public static func fromJSValue(context: JSContext, input: JSValue): A {
        let obj = input.asObject()
        A(
        Float64.fromJSValue(context, obj["p"])
        )
    }
}

/*interface B {
    p1: number;
    }*/

public open class B <: A {
    public var p1: Float64
    protected init(p: Float64,
    p1: Float64) {
        super( p )
        this.p1 = p1
    }

    public open func toJSValue(context: JSContext): JSValue {
        let obj = context.object()
        obj["p"] = p.toJSValue(context)
        obj["p1"] = p1.toJSValue(context)
        obj.toJSValue()
    }

    public static func fromJSValue(context: JSContext, input: JSValue): B {
        let obj = input.asObject()
        B(
        Float64.fromJSValue(context, obj["p"]),
        Float64.fromJSValue(context, obj["p1"])
        )
    }
}

/*interface C {
    f(): void
    }*/

public open class C {
    protected C(var arkts_object: JSObject) { }

    /**
     * @brief f(): void
     */
    public func f(): Unit {
        jsObjApiCall < Unit >( arkts_object, "f", EMPTY_ARG)
    }

    public open func toJSValue(_: JSContext): JSValue {
        arkts_object.toJSValue()
    }

    public static func fromJSValue(_: JSContext, input: JSValue): C {
        C(input.asObject())
    }
}

/*interface D {
    }*/

public open class D <: C {
    protected D(arkts_object: JSObject) { super(arkts_object) }

    public open func toJSValue(_: JSContext): JSValue {
        arkts_object.toJSValue()
    }

    public static func fromJSValue(_: JSContext, input: JSValue): D {
        D(input.asObject())
    }
}

/*interface E {
    }*/

public open class E <: A {
    protected init(p: Float64) {
        super( p )
    }

    public open func toJSValue(context: JSContext): JSValue {
        let obj = context.object()
        obj["p"] = p.toJSValue(context)
        obj.toJSValue()
    }

    public static func fromJSValue(context: JSContext, input: JSValue): E {
        let obj = input.asObject()
        E(
        Float64.fromJSValue(context, obj["p"])
        )
    }
}

/*interface F {
    g(): void
    }*/

public open class F <: C {
    protected F(arkts_object: JSObject) { super(arkts_object) }

    /**
     * @brief g(): void
     */
    public func g(): Unit {
        jsObjApiCall < Unit >( arkts_object, "g", EMPTY_ARG)
    }

    public open func toJSValue(_: JSContext): JSValue {
        arkts_object.toJSValue()
    }

    public static func fromJSValue(_: JSContext, input: JSValue): F {
        F(input.asObject())
    }
}
```

#### 嵌套对象

.d.ts 代码：

```typescript
// userProfile.d.ts
interface UserProfile {
  id: number;
  name: string;
  address: {
    city: string;
    zipCode: string;
  };
}
```

生成的仓颉代码：

```cangjie
/*interface AutoGenType0 {
    city: string;
    zipCode: string;
    }*/

public open class AutoGenType0 {
    public var city: String
    public var zipCode: String
    protected init(
    city: String,
    zipCode: String) {
        this.city = city
        this.zipCode = zipCode
    }

    public open func toJSValue(context: JSContext): JSValue {
        let obj = context.object()
        obj["city"] = city.toJSValue(context)
        obj["zipCode"] = zipCode.toJSValue(context)
        obj.toJSValue()
    }

    public static func fromJSValue(context: JSContext, input: JSValue): AutoGenType0 {
        let obj = input.asObject()
        AutoGenType0(
        String.fromJSValue(context, obj["city"]),
        String.fromJSValue(context, obj["zipCode"])
        )
    }
}

/*interface UserProfile {
    id: number;
    name: String;
    address: {
    city: String;
    zipCode: String;
  };
    }*/

public open class UserProfile {
    public var id: Float64
    public var name: String
    public var address: AutoGenType0
    protected init(
    id: Float64,
    name: String,
    address: AutoGenType0) {
        this.id = id
        this.name = name
        this.address = address
    }

    public open func toJSValue(context: JSContext): JSValue {
        let obj = context.object()
        obj["id"] = id.toJSValue(context)
        obj["name"] = name.toJSValue(context)
        obj["address"] = address.toJSValue(context)
        obj.toJSValue()
    }

    public static func fromJSValue(context: JSContext, input: JSValue): UserProfile {
        let obj = input.asObject()
        UserProfile(
        Float64.fromJSValue(context, obj["id"]),
        String.fromJSValue(context, obj["name"]),
        AutoGenType0.fromJSValue(context, obj["address"])
        )
    }
}
```

目前不支持

#### 索引签名

.d.ts 代码：

```typescript
// dictionary.d.ts
interface Dictionary {
  [key: string]: string;
}
// 使用
const dict: Dictionary = {
  name: 'Alice',
  job: 'Developer',
};
console.log(dict['name']); // Alice
```

目前还不支持

#### 动态属性

.d.ts 代码：

```typescript
// config.d.ts
interface Config {
  [key: string]: string | number;
}
```

目前不支持

#### 构造函数

.d.ts 代码：

```typescript
interface ClockConstructor {
  new (hour: number, minute: number): ClockInterface;
}
```

目前不支持

### 类型别名

- 支持枚举类型别名、class 类型别名、函数类型别名、联合类型别名。
- 不支持对象字面量类型别名、命名空间中的类型的类型别名、交叉类型别名、泛型类型别名。

#### 对象字面量类型别名

.d.ts 代码：

```typescript
  type AppConfig = {
    apiUrl: string;
    timeout: number;
  };

  declare const config: AppConfig;
```

目前不支持

#### 枚举类型别名

.d.ts 代码：

```typescript
declare enum Colors {
  Red = 'RED',
  Green = 'GREEN',
  Blue = 'BLUE',
}

type ColorAlias = Colors;
```

生成的仓颉代码：

```cangjie
public type ColorAlias = Colors

/***********ENUM***********/

/* enum Colors {
     Red = RED,
     Green = GREEN,
     Blue = BLUE
    }*/
public enum Colors <: ToString & Equatable < Colors > {
    | Red
    | Green
    | Blue

    func get(): String {
        match(this) {
            case Red => "RED"
            case Green => "GREEN"
            case Blue => "BLUE"
        }
    }

    static func parse(val: String): Colors {
        match(val) {
            case "RED" => Red
            case "GREEN" => Green
            case "BLUE" => Blue
            case _ => throw IllegalArgumentException("unknown value ${val}")
        }
    }

    static func tryParse(val: ?String): ?Colors {
        match(val) {
            case Some(v) => parse(v)
            case None => None
        }
    }

    public func toString(): String {
        get()
    }

    public override operator func ==(that: Colors): Bool {
        match((this, that)) {
            case(Red, Red) => true
            case(Green, Green) => true
            case(Blue, Blue) => true
            case _ => false
        }
    }

    public override operator func !=(that: Colors): Bool {
        !(this == that)
    }
}
```

#### class 类型别名

.d.ts 代码：

```typescript
  declare class Animal {
    name: string;
    constructor(name: string);
    speak(): void;
  }

  type AnimalAlias = Animal;
```

生成的仓颉代码：

```cangjie
public type AnimalAlias = Animal

/*class DeclareKeyword Animal {
    name: String;
    constructor(name: string): void
    speak(): void
    }*/

public class Animal {
    protected Animal(var arkts_object: JSObject) { }
    /**
     * @brief constructor(name: string): void
     */
    public init(name: String) {
        arkts_object = checkThreadAndCall < JSObject >(getMainContext()) {
            ctx =>
            let clazz = getClassConstructorObj("doc_dts_examples_ex_12_Animal", "Animal").toJSValue().asClass()
            clazz.new(name.toJSValue(ctx)).asObject()
        }
    }

    public mut prop name: String {
        get() {
            checkThreadAndCall < String >(getMainContext()) {
                ctx: JSContext => String.fromJSValue(ctx, arkts_object["name"])
            }
        }
        set(v) {
            checkThreadAndCall < Unit >(getMainContext()) {
                ctx: JSContext => arkts_object["name"] = v.toJSValue(ctx)
            }
        }

    }

    /**
     * @brief speak(): void
     */
    public func speak(): Unit {
        jsObjApiCall < Unit >( arkts_object, "speak", EMPTY_ARG)
    }

    func toJSValue(_: JSContext): JSValue {
        arkts_object.toJSValue()
    }

    static func fromJSValue(_: JSContext, input: JSValue): Animal {
        Animal(input.asObject())
    }
}
```

#### 命名空间中的类型的类型别名

.d.ts 代码：

```typescript
declare namespace Shapes {
  type Circle = { radius: number };
  type Rectangle = { width: number; height: number };
}

type CircleAlias = Shapes.Circle;
type RectangleAlias = Shapes.Rectangle;
```

目前不支持

#### 函数类型别名

.d.ts 代码：

```typescript
type MathOperation = (a: number, b: number) => number;
```

生成的仓颉代码：

```cangjie
public type MathOperation = (Float64, Float64) -> Float64
```

#### 联合类型别名

.d.ts 代码：

```typescript
type GreetingLike = string | number;
```

生成的仓颉代码：

```cangjie
public enum GreetingLike {
    | STRING(String)
    | NUMBER(Float64)

    public func toJSValue(context: JSContext): JSValue {
        match(this) {
            case STRING(x) => context.string(x).toJSValue()
            case NUMBER(x) => context.number(x).toJSValue()
        }
    }
    public static func fromJSValue(context: JSContext, input: JSValue): GreetingLike {

        if (input.isString()) {
            return STRING(String.fromJSValue(context, input))
        }
        if (input.isNumber()) {
            return NUMBER(Float64.fromJSValue(context, input))
        }
        throw Exception("unsupport type!")
    }
}
```

#### 交叉类型别名

.d.ts 代码：

```typescript
// point.d.ts
interface Point {
  readonly x: number;
  readonly y: number;
}
```

目前不支持

#### 泛型类型别名

.d.ts 代码：

```typescript
// point.d.ts
interface Point {
  readonly x: number;
  readonly y: number;
}
```

目前不支持

### 类

- 支持构造函数、静态成员、私有成员、保护成员、私有属性、泛型成员、抽象类、类实现接口、继承类、重载方法。
- 不支持索引签名、继承、动态属性、嵌套对象、函数类型、构造函数。

#### 构造函数

.d.ts 代码：

```typescript
declare class Greeter {
  constructor(greeting: string);
  greeting: string;
  showGreeting(): void;
}
```

生成的仓颉代码：

```cangjie
/*class DeclareKeyword Greeter {
    greeting: String;
    constructor(greeting: string): void
    showGreeting(): void
    }*/

public class Greeter {
    protected Greeter(var arkts_object: JSObject) { }
    /**
     * @brief constructor(greeting: string): void
     */
    public init(greeting: String) {
        arkts_object = checkThreadAndCall < JSObject >(getMainContext()) {
            ctx =>
            let clazz = getClassConstructorObj("_ark_interop_api", "Greeter").toJSValue().asClass()
            clazz.new(greeting.toJSValue(ctx)).asObject()
        }
    }

    public mut prop greeting: String {
        get() {
            checkThreadAndCall < String >(getMainContext()) {
                ctx: JSContext => String.fromJSValue(ctx, arkts_object["greeting"])
            }
        }
        set(v) {
            checkThreadAndCall < Unit >(getMainContext()) {
                ctx: JSContext => arkts_object["greeting"] = v.toJSValue(ctx)
            }
        }

    }

    /**
     * @brief showGreeting(): void
     */
    public func showGreeting(): Unit {
        jsObjApiCall < Unit >( arkts_object, "showGreeting", EMPTY_ARG)
    }

    func toJSValue(_: JSContext): JSValue {
        arkts_object.toJSValue()
    }

    static func fromJSValue(_: JSContext, input: JSValue): Greeter {
        Greeter(input.asObject())
    }
}
```

#### 静态成员

.d.ts 代码：

```typescript
// MathUtils.d.ts
declare class MathUtils {
  // 静态属性
  static PI: number;
  // 静态方法
  static square(x: number): number;
}
```

生成的仓颉代码：

```cangjie
/*class DeclareKeyword MathUtils {
    StaticKeywordPI: number;
    square(x: number): number
    }*/

public class MathUtils {
    protected MathUtils(var arkts_object: JSObject) { }

    public static mut prop PI: Float64 {
        get() {
            checkThreadAndCall < Float64 >(getMainContext()) {
                ctx: JSContext => Float64.fromJSValue(ctx, getClassConstructorObj("_ark_interop_api", "MathUtils")["PI"])
            }
        }
        set(v) {
            checkThreadAndCall < Unit >(getMainContext()) {
                ctx: JSContext => getClassConstructorObj("_ark_interop_api", "MathUtils")["PI"] = v.toJSValue(ctx)
            }
        }

    }

    /**
     * @brief square(x: number): number
     */
    public static func square(x: Float64): Float64 {
        jsObjApiCall < Float64 >(getClassConstructorObj("_ark_interop_api", "MathUtils"),  "square", { ctx =>[x.toJSValue(ctx)] })
    }

    func toJSValue(_: JSContext): JSValue {
        arkts_object.toJSValue()
    }

    static func fromJSValue(_: JSContext, input: JSValue): MathUtils {
        MathUtils(input.asObject())
    }
}
```

#### 私有成员

.d.ts 代码：

```typescript
declare class Person {
    // 私有属性
    private age: number;

  }
```

生成的仓颉代码：

```cangjie
/*class DeclareKeyword Person {
    }*/

public class Person {
    protected Person(var arkts_object: JSObject) { }

    func toJSValue(_: JSContext): JSValue {
        arkts_object.toJSValue()
    }

    static func fromJSValue(_: JSContext, input: JSValue): Person {
        Person(input.asObject())
    }
}
```

#### 保护成员

.d.ts 代码：

```typescript
declare class AnimalProtect {
    // 受保护属性
    protected name: string;

    // 受保护方法
    protected makeSound(): void;
}
```

生成的仓颉代码：

```cangjie
/*class DeclareKeyword AnimalProtect {
    ProtectedKeywordname: String;
    makeSound(): void
    }*/

public class AnimalProtect {
    protected AnimalProtect(var arkts_object: JSObject) { }

    public mut prop name: String {
        get() {
            checkThreadAndCall < String >(getMainContext()) {
                ctx: JSContext => String.fromJSValue(ctx, arkts_object["name"])
            }
        }
        set(v) {
            checkThreadAndCall < Unit >(getMainContext()) {
                ctx: JSContext => arkts_object["name"] = v.toJSValue(ctx)
            }
        }

    }

    /**
     * @brief makeSound(): void
     */
    public func makeSound(): Unit {
        jsObjApiCall < Unit >( arkts_object, "makeSound", EMPTY_ARG)
    }

    func toJSValue(_: JSContext): JSValue {
        arkts_object.toJSValue()
    }

    static func fromJSValue(_: JSContext, input: JSValue): AnimalProtect {
        AnimalProtect(input.asObject())
    }
}
```

#### 只读属性

.d.ts 代码：

```typescript
declare class Car {
    // 只读属性
    readonly brand: string;
    name: string
  }
```

生成的仓颉代码：

```cangjie
/*class DeclareKeyword Car {
    ReadonlyKeywordbrand: String;
    name: String;
    }*/

public class Car {
    protected Car(var arkts_object: JSObject) { }

    public prop brand: String {
        get() {
            checkThreadAndCall < String >(getMainContext()) {
                ctx: JSContext => String.fromJSValue(ctx, arkts_object["brand"])
            }
        }
    }

    public mut prop name: String {
        get() {
            checkThreadAndCall < String >(getMainContext()) {
                ctx: JSContext => String.fromJSValue(ctx, arkts_object["name"])
            }
        }
        set(v) {
            checkThreadAndCall < Unit >(getMainContext()) {
                ctx: JSContext => arkts_object["name"] = v.toJSValue(ctx)
            }
        }

    }

    func toJSValue(_: JSContext): JSValue {
        arkts_object.toJSValue()
    }

    static func fromJSValue(_: JSContext, input: JSValue): Car {
        Car(input.asObject())
    }
}
```

#### 泛型成员

.d.ts 代码：

```typescript
declare class Box<T> {
    // 属性
    value: T;
    // 方法
    getValue(): T;
  }
```

生成的仓颉代码：

```cangjie
/*class DeclareKeyword Box {
    value: T;
    getValue(): T
    }*/

public class Box<T> where T <: JSInteropType<T> {
    protected Box(var arkts_object: JSObject) { }

    public mut prop value: T {
        get() {
            checkThreadAndCall < T >(getMainContext()) {
                ctx: JSContext => T.fromJSValue(ctx, arkts_object["value"])
            }
        }
        set(v) {
            checkThreadAndCall < Unit >(getMainContext()) {
                ctx: JSContext => arkts_object["value"] = v.toJSValue(ctx)
            }
        }

    }

    /**
     * @brief getValue(): T
     */
    public func getValue(): T {
        jsObjApiCall < T >( arkts_object, "getValue", EMPTY_ARG) { ctx, info => T.fromJSValue(ctx, info) }
    }

    func toJSValue(_: JSContext): JSValue {
        arkts_object.toJSValue()
    }

    static func fromJSValue(_: JSContext, input: JSValue): Box<T> {
        Box(input.asObject())
    }
}
```

#### 抽象类

.d.ts 代码：

```typescript
declare abstract class Shape {
    // 抽象方法
    abstract getArea(): number;
  }
```

生成的仓颉代码：

```cangjie
/*class DeclareKeyword FirstContextualKeyword Shape {
    getArea(): number
    }*/

public open class Shape {
    protected Shape(var arkts_object: JSObject) { }

    /**
     * @brief getArea(): number
     */
    public func getArea(): Float64 {
        jsObjApiCall < Float64 >( arkts_object, "getArea", EMPTY_ARG)
    }

    public open func toJSValue(_: JSContext): JSValue {
        arkts_object.toJSValue()
    }

    public static func fromJSValue(_: JSContext, input: JSValue): Shape {
        Shape(input.asObject())
    }
}
```

#### 类实现接口

.d.ts 代码：

```typescript
interface Drivable {
  start(): void;
  stop(): void;
}

declare class Car implements Drivable {
  start(): void;
  stop(): void;
}
```

生成的仓颉代码：

```cangjie
/*interface Drivable {
    start(): void
    stop(): void
    }*/

public open class Drivable {
    protected Drivable(var arkts_object: JSObject) { }

    /**
     * @brief start(): void
     */
    public func start(): Unit {
        jsObjApiCall < Unit >( arkts_object, "start", EMPTY_ARG)
    }
    /**
     * @brief stop(): void
     */
    public func stop(): Unit {
        jsObjApiCall < Unit >( arkts_object, "stop", EMPTY_ARG)
    }

    public open func toJSValue(_: JSContext): JSValue {
        arkts_object.toJSValue()
    }

    public static func fromJSValue(_: JSContext, input: JSValue): Drivable {
        Drivable(input.asObject())
    }
}

/*class DeclareKeyword Car {
    start(): void
    stop(): void
    }*/

public class Car <: Drivable {
    protected Car(arkts_object: JSObject) { super(arkts_object) }

    public func toJSValue(_: JSContext): JSValue {
        arkts_object.toJSValue()
    }

    public static func fromJSValue(_: JSContext, input: JSValue): Car {
        Car(input.asObject())
    }
}
```

#### 继承类

.d.ts 代码：

```typescript
// Animal.d.ts
declare class Animal {
  name: string;
  constructor(name: string);
  move(distance: number): void;
}

// Dog.d.ts
declare class Dog extends Animal {
  bark(): void;
}
```

生成的仓颉代码：

```cangjie
/*class DeclareKeyword Animal {
    name: String;
    constructor(name: string): void
    move(distance: number): void
    }*/

public open class Animal {
    protected Animal(var arkts_object: JSObject) { }
    /**
     * @brief constructor(name: string): void
     */
    public init(name: String) {
        arkts_object = checkThreadAndCall < JSObject >(getMainContext()) {
            ctx =>
            let clazz = getClassConstructorObj("_ark_interop_api", "Animal").toJSValue().asClass()
            clazz.new(name.toJSValue(ctx)).asObject()
        }
    }

    public mut prop name: String {
        get() {
            checkThreadAndCall < String >(getMainContext()) {
                ctx: JSContext => String.fromJSValue(ctx, arkts_object["name"])
            }
        }
        set(v) {
            checkThreadAndCall < Unit >(getMainContext()) {
                ctx: JSContext => arkts_object["name"] = v.toJSValue(ctx)
            }
        }

    }

    /**
     * @brief move(distance: number): void
     */
    public func move(distance: Float64): Unit {
        jsObjApiCall < Unit >( arkts_object, "move", { ctx =>[distance.toJSValue(ctx)] })
    }

    public open func toJSValue(_: JSContext): JSValue {
        arkts_object.toJSValue()
    }

    public static func fromJSValue(_: JSContext, input: JSValue): Animal {
        Animal(input.asObject())
    }
}

/*class DeclareKeyword Dog {
    bark(): void
    }*/

public class Dog <: Animal {
    protected Dog(arkts_object: JSObject) { super(arkts_object) }

    /**
     * @brief bark(): void
     */
    public func bark(): Unit {
        jsObjApiCall < Unit >( arkts_object, "bark", EMPTY_ARG)
    }

    public func toJSValue(_: JSContext): JSValue {
        arkts_object.toJSValue()
    }

    public static func fromJSValue(_: JSContext, input: JSValue): Dog {
        Dog(input.asObject())
    }
}
```

#### 重载方法

.d.ts 代码：

```typescript
declare class Calculator {
    // 方法重载
    add(x: number, y: number): number;
    add(x: string, y: string): string;

    // 实现
    add(x: any, y: any): any;
  }
```

生成的仓颉代码：

```cangjie
/*class DeclareKeyword Calculator {
    add(x: number, y: number): number
    add(x: string, y: string): String
    add(x: any, y: any): any
    }*/

public class Calculator {
    protected Calculator(var arkts_object: JSObject) { }

    /**
     * @brief add(x: number, y: number): number
     */
    public func add(x: Float64, y: Float64): Float64 {
        jsObjApiCall < Float64 >( arkts_object, "add", { ctx =>[x.toJSValue(ctx), y.toJSValue(ctx)] })
    }
    /**
     * @brief add(x: string, y: string): String
     */
    public func add(x: String, y: String): String {
        jsObjApiCall < String >( arkts_object, "add", { ctx =>[x.toJSValue(ctx), y.toJSValue(ctx)] })
    }
    /**
     * @brief add(x: any, y: any): any
     */
    public func add(x: JSValue/* FIXME: `any` */, y: JSValue/* FIXME: `any` */): JSValue/* FIXME: `any` */ {
        jsObjApiCall < JSValue/* FIXME: `any` */ >( arkts_object, "add", { ctx =>[x, y] }) { ctx, info => info }
    }

    func toJSValue(_: JSContext): JSValue {
        arkts_object.toJSValue()
    }

    static func fromJSValue(_: JSContext, input: JSValue): Calculator {
        Calculator(input.asObject())
    }
}
```

#### 带装饰器的类

.d.ts 代码：

```typescript
// LogClass.d.ts
declare function logClass(target: any): void;

@logClass
declare class MyClass {
  name: string;
  constructor(name: string);
}
```

目前不支持

#### 带命名空间的类

.d.ts 代码：

```typescript
// Shapes.d.ts
declare namespace Shapes {
  class Circle1 {
    radius: number;
    constructor(radius: number);
    getArea(): number;
  }
}
```

目前不支持

### 枚举

- 支持字符串枚举、数字枚举、常量枚举、异构枚举。其中，在仓颉胶水代码里，异构枚举中所有类型的枚举值都会被转换成字符串类型。因此，开发者调用胶水代码时，需要将非字符串类型（例如 number 类型）的异构枚举成员手动转换为 ArkTS 中定义的原类型。
- 不支持计算值枚举。

#### 字符串枚举

.d.ts 代码：

```typescript
// colors.d.ts
declare enum Colors {
  Red = 'RED',
  Green = 'GREEN',
  Blue = 'BLUE',
}
```

生成的仓颉代码：

```cangjie
/***********ENUM***********/

/* enum Colors {
     Red = RED,
     Green = GREEN,
     Blue = BLUE
    }*/
public enum Colors <: ToString & Equatable < Colors > {
    | Red
    | Green
    | Blue

    func get(): String {
        match(this) {
            case Red => "RED"
            case Green => "GREEN"
            case Blue => "BLUE"
        }
    }

    static func parse(val: String): Colors {
        match(val) {
            case "RED" => Red
            case "GREEN" => Green
            case "BLUE" => Blue
            case _ => throw IllegalArgumentException("unknown value ${val}")
        }
    }

    static func tryParse(val: ?String): ?Colors {
        match(val) {
            case Some(v) => parse(v)
            case None => None
        }
    }

    public func toString(): String {
        get()
    }

    public override operator func ==(that: Colors): Bool {
        match((this, that)) {
            case(Red, Red) => true
            case(Green, Green) => true
            case(Blue, Blue) => true
            case _ => false
        }
    }

    public override operator func !=(that: Colors): Bool {
        !(this == that)
    }
}
```

#### 数字枚举

.d.ts 代码：

```typescript
// status.d.ts
declare enum Status {
  Pending,    // 0
  Approved,   // 1
  Rejected,   // 2
}
```

生成的仓颉代码：

```cangjie
/***********ENUM***********/

/* enum Status {
     Pending,
     Approved,
     Rejected
    }*/
public enum Status <: ToString & Equatable < Status > {
    | Pending
    | Approved
    | Rejected

    func get(): Int32 {
        match(this) {
            case Pending => 0  //todo: please check the value
            case Approved => 1  //todo: please check the value
            case Rejected => 2  //todo: please check the value
        }
    }

    static func parse(val: Int32): Status {
        match(val) {
            case 0 => Pending  //todo: please check the value
            case 1 => Approved  //todo: please check the value
            case 2 => Rejected  //todo: please check the value
            case _ => throw IllegalArgumentException("unknown value ${val}")
        }
    }

    static func tryParse(val: ?Int32): ?Status {
        match(val) {
            case Some(v) => parse(v)
            case None => None
        }
    }

    public func toString(): String {
        match(this) {
            case Pending => "Pending"
            case Approved => "Approved"
            case Rejected => "Rejected"
        }
    }

    public override operator func ==(that: Status): Bool {
        match((this, that)) {
            case(Pending, Pending) => true
            case(Approved, Approved) => true
            case(Rejected, Rejected) => true
            case _ => false
        }
    }

    public override operator func !=(that: Status): Bool {
        !(this == that)
    }
}
```

#### 常量枚举

.d.ts 代码：

```typescript
// constants.d.ts
declare const enum Status {
  Pending = 3,
  Approved = 4,
  Rejected = 5
}
```

生成的仓颉代码：

```cangjie
/***********ENUM***********/

/* enum Status {
     Pending = 3,
     Approved = 4,
     Rejected = 5
    }*/
public enum Status <: ToString & Equatable < Status > {
    | Pending
    | Approved
    | Rejected

    func get(): Int32 {
        match(this) {
            case Pending => 3
            case Approved => 4
            case Rejected => 5
        }
    }

    static func parse(val: Int32): Status {
        match(val) {
            case 3 => Pending
            case 4 => Approved
            case 5 => Rejected
            case _ => throw IllegalArgumentException("unknown value ${val}")
        }
    }

    static func tryParse(val: ?Int32): ?Status {
        match(val) {
            case Some(v) => parse(v)
            case None => None
        }
    }

    public func toString(): String {
        match(this) {
            case Pending => "Pending"
            case Approved => "Approved"
            case Rejected => "Rejected"
        }
    }

    public override operator func ==(that: Status): Bool {
        match((this, that)) {
            case(Pending, Pending) => true
            case(Approved, Approved) => true
            case(Rejected, Rejected) => true
            case _ => false
        }
    }

    public override operator func !=(that: Status): Bool {
        !(this == that)
    }
}
```

#### 异构枚举

.d.ts 代码：

```typescript
// response.d.ts
declare enum Response {
  No = 0,
  Yes = 'YES',
}
```

生成的仓颉代码：

```cangjie
/***********ENUM***********/

/* enum Response {
     No = 0,
     Yes = YES
    }*/
public enum Response <: ToString & Equatable < Response > {
    | No
    | Yes

    func get(): String {
        match(this) {
            case No => "0"
            case Yes => "YES"
        }
    }

    static func parse(val: String): Response {
        match(val) {
            case "0" => No
            case "YES" => Yes
            case _ => throw IllegalArgumentException("unknown value ${val}")
        }
    }

    static func tryParse(val: ?String): ?Response {
        match(val) {
            case Some(v) => parse(v)
            case None => None
        }
    }

    public func toString(): String {
        get()
    }

    public override operator func ==(that: Response): Bool {
        match((this, that)) {
            case(No, No) => true
            case(Yes, Yes) => true
            case _ => false
        }
    }

    public override operator func !=(that: Response): Bool {
        !(this == that)
    }
}
```

## 类型映射关系

ArkTS 的 .d.ts 接口转换到互操作的仓颉代码，支持的类型转换有：基础类型、Array 类型、函数类型、Optional 类型、Object 类型、tuple 类型、Union 类型、Promise 类型。

对于不支持的类型，会默认改成 JSValue 类型，并且会添加一个 FIXME 的注释（注释中会填写原始的 .d.ts 声明中的类型），命令行也会打印类型不支持的告警信息。

- 注释的格式

  .d.ts 代码：

  ```typescript
  type TA80 = undefined;
  ```

  对应的仓颉代码：

  ```typescript
  // 对应的仓颉代码的类型是JSValue，并且会带FIXME的注释信息，其中填写的.d.ts中声明的类型
  public type TA80 = JSValue/* FIXME: `undefined` */
  ```

- 告警信息的格式：

  ```typescript
  WARNING: type is not supported - undefined
  ```

### 基础类型

支持的数据类型有：

| ArkTS 类型 | 仓颉类型 |
| --------- | -------- |
| string    | String   |
| number    | Float64  |
| boolean   | Bool     |
| bigint    | BigInt   |
| object    | JSValue  |
| symbol    | JSValue  |
| void      | Unit     |
| undefined | JSValue  |
| any       | JSValue  |
| unknown   | JSValue  |
| never     | JSValue  |

示例：

.d.ts 代码：

```typescript
interface BasicTypes {
    numberKeyword: number;
    stringKeyword: string;
    booleanKeyword: boolean;
    bigintKeyword: bigint;
    objectKeyword: object;
    symbolKeyword: symbol;
    voidKeyword: void;
    undefinedKeyword: undefined;
    anyKeyword: any;
    unknownKeyword: unknown;
    neverKeyword: never;
}
```

生成的仓颉代码：

```cangjie
/*interface BasicTypes {
    numberKeyword: number;
    stringKeyword: String;
    booleanKeyword: boolean;
    bigintKeyword: bigint;
    objectKeyword: object;
    symbolKeyword: symbol;
    voidKeyword: void;
    undefinedKeyword: undefined;
    anyKeyword: any;
    unknownKeyword: unknown;
    neverKeyword: never;
    }*/

public open class BasicTypes {
    public var numberKeyword: Float64
    public var stringKeyword: String
    public var booleanKeyword: Bool
    public var bigintKeyword: BigInt
    public var objectKeyword: JSValue/* FIXME: `object` */
    public var symbolKeyword: JSValue/* FIXME: `symbol` */
    public var voidKeyword: Unit
    public var undefinedKeyword: JSValue/* FIXME: `undefined` */
    public var anyKeyword: JSValue/* FIXME: `any` */
    public var unknownKeyword: JSValue/* FIXME: `unknown` */
    public var neverKeyword: JSValue/* FIXME: `never` */
    protected init(
    numberKeyword: Float64,
    stringKeyword: String,
    booleanKeyword: Bool,
    bigintKeyword: BigInt,
    objectKeyword: JSValue/* FIXME: `object` */,
    symbolKeyword: JSValue/* FIXME: `symbol` */,
    voidKeyword: Unit,
    undefinedKeyword: JSValue/* FIXME: `undefined` */,
    anyKeyword: JSValue/* FIXME: `any` */,
    unknownKeyword: JSValue/* FIXME: `unknown` */,
    neverKeyword: JSValue/* FIXME: `never` */) {
        this.numberKeyword = numberKeyword
        this.stringKeyword = stringKeyword
        this.booleanKeyword = booleanKeyword
        this.bigintKeyword = bigintKeyword
        this.objectKeyword = objectKeyword
        this.symbolKeyword = symbolKeyword
        this.voidKeyword = voidKeyword
        this.undefinedKeyword = undefinedKeyword
        this.anyKeyword = anyKeyword
        this.unknownKeyword = unknownKeyword
        this.neverKeyword = neverKeyword
    }

    public open func toJSValue(context: JSContext): JSValue {
        let obj = context.object()
        obj["numberKeyword"] = numberKeyword.toJSValue(context)
        obj["stringKeyword"] = stringKeyword.toJSValue(context)
        obj["booleanKeyword"] = booleanKeyword.toJSValue(context)
        obj["bigintKeyword"] = context.bigint(bigintKeyword).toJSValue()
        obj["objectKeyword"] = objectKeyword
        obj["symbolKeyword"] = symbolKeyword
        obj["voidKeyword"] = voidKeyword.toJSValue(context)
        obj["undefinedKeyword"] = undefinedKeyword
        obj["anyKeyword"] = anyKeyword
        obj["unknownKeyword"] = unknownKeyword
        obj["neverKeyword"] = neverKeyword
        obj.toJSValue()
    }

    public static func fromJSValue(context: JSContext, input: JSValue): BasicTypes {
        let obj = input.asObject()
        BasicTypes(
        Float64.fromJSValue(context, obj["numberKeyword"]),
        String.fromJSValue(context, obj["stringKeyword"]),
        Bool.fromJSValue(context, obj["booleanKeyword"]),
        obj["bigintKeyword"].asBigInt().toBigInt(),
        obj["objectKeyword"],
        obj["symbolKeyword"],
        Unit.fromJSValue(context, obj["voidKeyword"]),
        obj["undefinedKeyword"],
        obj["anyKeyword"],
        obj["unknownKeyword"],
        obj["neverKeyword"]
        )
    }
}
```

### Array

Array 目前支持 4 种类型转换：

| ArkTS 类型                     | 仓颉类型       |
| ----------------------------- | -------------- |
| Uint8Array                    | Array\<UInt8>   |
| ArrayBuffer                   | Array\<UInt8>   |
| Float32Array                  | Array\<Float32> |
| 基本类型的 array，比如 number[] | Array\<Float64> |

示例：

.d.ts 代码：

```typescript
interface arrayInterface {
  arrayType1: number[];
  arrayType2: Uint8Array;
  arrayType3: ArrayBuffer;
  arrayType4: Float32Array;
}
```

生成的仓颉代码：

```cangjie
/*interface arrayInterface {
    arrayType1: number[];
    arrayType2: Uint8Array;
    arrayType3: ArrayBuffer;
    arrayType4: Float32Array;
    }*/

public open class arrayInterface {
    public var arrayType1: Array<Float64>
    public var arrayType2: Array<UInt8>
    public var arrayType3: Array<UInt8>
    public var arrayType4: Array<Float32>
    protected init(
    arrayType1: Array<Float64>,
    arrayType2: Array<UInt8>,
    arrayType3: Array<UInt8>,
    arrayType4: Array<Float32>) {
        this.arrayType1 = arrayType1
        this.arrayType2 = arrayType2
        this.arrayType3 = arrayType3
        this.arrayType4 = arrayType4
    }

    public open func toJSValue(context: JSContext): JSValue {
        let obj = context.object()
        obj["arrayType1"] = toJSArray < Float64 >(context, arrayType1)
        obj["arrayType2"] = toJSArray < UInt8 >(context, arrayType2, { ctx: JSContext, val: UInt8 => val.toJSValue(ctx) })
        obj["arrayType3"] = toJSArray < UInt8 >(context, arrayType3, { ctx: JSContext, val: UInt8 => val.toJSValue(ctx) })
        obj["arrayType4"] = toJSArray < Float32 >(context, arrayType4, { ctx: JSContext, val: Float32 => val.toJSValue(ctx) })
        obj.toJSValue()
    }

    public static func fromJSValue(context: JSContext, input: JSValue): arrayInterface {
        let obj = input.asObject()
        arrayInterface(
        fromJSArray < Float64 >(context, obj["arrayType1"]),
        fromJSArray < UInt8 >(context, obj["arrayType2"], { ctx: JSContext, val: JSValue => UInt8.fromJSValue(ctx, val) }),
        fromJSArray < UInt8 >(context, obj["arrayType3"], { ctx: JSContext, val: JSValue => UInt8.fromJSValue(ctx, val) }),
        fromJSArray < Float32 >(context, obj["arrayType4"], { ctx: JSContext, val: JSValue => Float32.fromJSValue(ctx, val) })
        )
    }
}
```

### 函数类型

- 支持接口属性、函数参数。
- `Function`类型不支持转换。

#### 接口属性

示例：

.d.ts 代码：

```typescript
interface TestListener {
    "onStart"?: () => void;
    "onDestroy"?: () => void;
    onError?: (code: ErrorCode, msg: string) => void;
    onTouch?: () => void;
    onEvent?: (e: EventType) => void;
}
```

生成的仓颉代码：

```cangjie
/*interface TestListener {
    onStart?: () => void;
    onDestroy?: () => void;
    onError?: (code: ErrorCode, msg: String) => void;
    onTouch?: () => void;
    onEvent?: (e: EventType) => void;
    }*/

public open class TestListener {
    public var onStart: Option<() -> Unit> = None
    public var onDestroy: Option<() -> Unit> = None
    public var onError: Option<(JSValue/* FIXME: `ErrorCode` */, String) -> Unit> = None
    public var onTouch: Option<() -> Unit> = None
    public var onEvent: Option<(JSValue/* FIXME: `EventType` */) -> Unit> = None
    protected init(
    onStart!: Option<() -> Unit> = None,
    onDestroy!: Option<() -> Unit> = None,
    onError!: Option<(JSValue/* FIXME: `ErrorCode` */, String) -> Unit> = None,
    onTouch!: Option<() -> Unit> = None,
    onEvent!: Option<(JSValue/* FIXME: `EventType` */) -> Unit> = None) {
        this.onStart = onStart
        this.onDestroy = onDestroy
        this.onError = onError
        this.onTouch = onTouch
        this.onEvent = onEvent
    }

    public open func toJSValue(context: JSContext): JSValue {
        let obj = context.object()
        if (let Some(v) <- onStart) {
            obj["onStart"] = context.function({ ctx, _ =>
                v()
                ctx.undefined().toJSValue()
            }).toJSValue()
        }
        if (let Some(v) <- onDestroy) {
            obj["onDestroy"] = context.function({ ctx, _ =>
                v()
                ctx.undefined().toJSValue()
            }).toJSValue()
        }
        if (let Some(v) <- onError) {
            obj["onError"] = context.function({ ctx, info =>
                let p0 = info[0]
                let p1 = String.fromJSValue(ctx, info[1])
                v(p0, p1)
                ctx.undefined().toJSValue()
            }).toJSValue()
        }
        if (let Some(v) <- onTouch) {
            obj["onTouch"] = context.function({ ctx, _ =>
                v()
                ctx.undefined().toJSValue()
            }).toJSValue()
        }
        if (let Some(v) <- onEvent) {
            obj["onEvent"] = context.function({ ctx, info =>
                let p0 = info[0]
                v(p0)
                ctx.undefined().toJSValue()
            }).toJSValue()
        }
        obj.toJSValue()
    }

    public static func fromJSValue(context: JSContext, input: JSValue): TestListener {
        let obj = input.asObject()
        TestListener(
        onStart: if (obj["onStart"].isUndefined()) {
            None
        } else {
            { =>
                checkThreadAndCall < Unit >(context, { _ =>
                    obj["onStart"].asFunction().call()
                })
            }
        },
        onDestroy: if (obj["onDestroy"].isUndefined()) {
            None
        } else {
            { =>
                checkThreadAndCall < Unit >(context, { _ =>
                    obj["onDestroy"].asFunction().call()
                })
            }
        },
        onError: if (obj["onError"].isUndefined()) {
            None
        } else {
            { code: JSValue/* FIXME: `ErrorCode` */, msg: String =>
                checkThreadAndCall < Unit >(context, { ctx =>
                    let arg0 = code
                    let arg1 = msg.toJSValue(ctx)
                    obj["onError"].asFunction().call([arg0, arg1])
                })
            }
        },
        onTouch: if (obj["onTouch"].isUndefined()) {
            None
        } else {
            { =>
                checkThreadAndCall < Unit >(context, { _ =>
                    obj["onTouch"].asFunction().call()
                })
            }
        },
        onEvent: if (obj["onEvent"].isUndefined()) {
            None
        } else {
            { e: JSValue/* FIXME: `EventType` */ =>
                checkThreadAndCall < Unit >(context, { ctx =>
                    let arg0 = e
                    obj["onEvent"].asFunction().call([arg0])
                })
            }
        }
        )
    }
}
```

#### 函数参数

示例：

.d.ts 代码：

```typescript
interface MyListener {
    on(key: string, param: boolean, cb: (r: Record<string, string>) => void);
}
```

生成的仓颉代码：

```cangjie
/*interface MyListener {
    on(key: string, param: boolean, cb: (r: Record<string, string>) => void): void
    }*/

public open class MyListener {
    let callbackManager = CallbackManager < String, JSValue >()

    protected MyListener(var arkts_object: JSObject) { }

    /**
     * @brief on(key: string, param: boolean, cb: (r: Record<string, string>) => void): void
     */
    public func on(key: String, param: Bool, cb: Callback1Argument<HashMap<String, String>>): Unit {
        let keyString = key.toString()
        if (callbackManager.findCallbackObject(keyString, cb).isSome()) {
            return
        }
        let jsCallback = checkThreadAndCall < JSValue >(getMainContext()) {
            ctx => ctx.function {
                ctx: JSContext, info: JSCallInfo =>
                let arg0 = record2Hashmap<String>(ctx, info[0], { context, i => String.fromJSValue(context, i) })
                cb.invoke(arg0)
                ctx.undefined().toJSValue()
            }.toJSValue()
        }
        callbackManager.put(keyString,(cb, jsCallback))
        jsObjApiCall < Unit >( arkts_object, "on", { ctx =>[keyString.toJSValue(ctx), param.toJSValue(ctx), jsCallback] })
    }
    public open func toJSValue(_: JSContext): JSValue {
        arkts_object.toJSValue()
    }

    public static func fromJSValue(_: JSContext, input: JSValue): MyListener {
        MyListener(input.asObject())
    }
}
```

### Optional 类型

示例：

.d.ts 代码：

```typescript
interface Optionals {
    optionalField1?: number;
    optionalParam10: (a: number, b?: string) => void;
}
```

生成的仓颉代码：

```cangjie
/*interface Optionals {
    optionalParam10: (a: number, b?: String) => void;
    optionalField1?: number;
    }*/

public open class Optionals {
    public var optionalParam10: (Float64, ?String) -> Unit
    public var optionalField1: Option<Float64> = None
    protected init(
    optionalParam10: (Float64, ?String) -> Unit,
    optionalField1!: Option<Float64> = None) {
        this.optionalParam10 = optionalParam10
        this.optionalField1 = optionalField1
    }

    public open func toJSValue(context: JSContext): JSValue {
        let obj = context.object()
        obj["optionalParam10"] = context.function({ ctx, info =>
            let p0 = Float64.fromJSValue(ctx, info[0])
            let p1 = String.fromJSValue(ctx, info[1])
            optionalParam10(p0, p1)
            ctx.undefined().toJSValue()
        }).toJSValue()
        if (let Some(v) <- optionalField1) {
            obj["optionalField1"] = v.toJSValue(context)
        }
        obj.toJSValue()
    }

    public static func fromJSValue(context: JSContext, input: JSValue): Optionals {
        let obj = input.asObject()
        Optionals(
        { a: Float64, b:?String =>
            checkThreadAndCall < Unit >(context, { ctx =>
                let arg0 = a.toJSValue(ctx)
                let arg1 = match(b) {
                    case None => ctx.undefined().toJSValue()
                    case _ => b.getOrThrow().toJSValue(ctx)
                }
                obj["optionalParam10"].asFunction().call([arg0, arg1])
            })
        },
        optionalField1:
        if (obj["optionalField1"].isNull()) {
            None < Float64 >
        } else {
            Float64.fromJSValue(context, obj["optionalField1"])
        }
        )
    }
}
```

### Object 类型

示例：

.d.ts 代码：

```typescript
interface ObjectTypes<U, T> {
    typeLiteral10: { x: number; y: U; };
    typeLiteral20: { [p: number]: string; [p: symbol]: T };
    typeLiteral30: { (): void; (number): string };
}
```

当前类型不支持，会默认转换成 JSValue。

生成的仓颉代码：

```cangjie
/*interface AutoGenType0 {
    x: number;
    y: U;
    }*/

public open class AutoGenType0<U> where U <: JSInteropType<U> {
    public var x: Float64
    public var y: U
    protected init(
    x: Float64,
    y: U) {
        this.x = x
        this.y = y
    }

    public open func toJSValue(context: JSContext): JSValue {
        let obj = context.object()
        obj["x"] = x.toJSValue(context)
        obj["y"] = y.toJSValue(context)
        obj.toJSValue()
    }

    public static func fromJSValue(context: JSContext, input: JSValue): AutoGenType0<U> {
        let obj = input.asObject()
        AutoGenType0(
        Float64.fromJSValue(context, obj["x"]),
        U.fromJSValue(context, obj["y"])
        )
    }
}

/*interface AutoGenType1 {
    }*/

public open class AutoGenType1 {
    protected init() {
    }

    public open func toJSValue(context: JSContext): JSValue {
        let obj = context.object()

        obj.toJSValue()
    }

    public static func fromJSValue(context: JSContext, input: JSValue): AutoGenType1 {
        let obj = input.asObject()
        AutoGenType1(

        )
    }
}

/*interface AutoGenType2 {
    }*/

public open class AutoGenType2 {
    protected init() {
    }

    public open func toJSValue(context: JSContext): JSValue {
        let obj = context.object()

        obj.toJSValue()
    }

    public static func fromJSValue(context: JSContext, input: JSValue): AutoGenType2 {
        let obj = input.asObject()
        AutoGenType2(

        )
    }
}

/*interface ObjectTypes {
    typeLiteral10: { x: number; y: U; };
    typeLiteral20: { [p: number]: String; [p: symbol]: T };
    typeLiteral30: { (): void; (number): String };
    }*/

public open class ObjectTypes<U, T> where U <: JSInteropType<U>, T <: JSInteropType<T> {
    public var typeLiteral10: AutoGenType0<U>
    public var typeLiteral20: AutoGenType1
    public var typeLiteral30: AutoGenType2
    protected init(
    typeLiteral10: AutoGenType0<U>,
    typeLiteral20: AutoGenType1,
    typeLiteral30: AutoGenType2) {
        this.typeLiteral10 = typeLiteral10
        this.typeLiteral20 = typeLiteral20
        this.typeLiteral30 = typeLiteral30
    }

    public open func toJSValue(context: JSContext): JSValue {
        let obj = context.object()
        obj["typeLiteral10"] = typeLiteral10.toJSValue(context)
        obj["typeLiteral20"] = typeLiteral20.toJSValue(context)
        obj["typeLiteral30"] = typeLiteral30.toJSValue(context)
        obj.toJSValue()
    }

    public static func fromJSValue(context: JSContext, input: JSValue): ObjectTypes<U, T> {
        let obj = input.asObject()
        ObjectTypes(
        AutoGenType0<U>.fromJSValue(context, obj["typeLiteral10"]),
        AutoGenType1.fromJSValue(context, obj["typeLiteral20"]),
        AutoGenType2.fromJSValue(context, obj["typeLiteral30"])
        )
    }
}
```

### tuple 类型

示例：

.d.ts 代码：

```typescript
tupleType: [number, number, string];
```

生成的仓颉代码：

```cangjie
public var tupleType: (Float64, Float64, String)
```

### Union 类型

- 目前只支持 union 类型作为类型别名和函数参数。

示例：

.d.ts 代码：

```typescript
type ARK1 = null | number | string | boolean | Uint8Array | Float32Array | bigint;
```

生成的仓颉代码：

```cangjie
public enum ARK1 {
    | NULL
    | NUMBER(Float64)
    | STRING(String)
    | BOOLEAN(Bool)
    | BYTEARRAY(Array<UInt8>)
    | FLOAT32ARRAY(Array<Float32>)
    | BIGINT(BigInt)

    public func toJSValue(context: JSContext): JSValue {
        match(this) {
            case NULL => context.null().toJSValue()
            case NUMBER(x) => context.number(x).toJSValue()
            case STRING(x) => context.string(x).toJSValue()
            case BOOLEAN(x) => context.boolean(x).toJSValue()
            case BYTEARRAY(x) => context.global["Uint8Array"].asClass().new(x.toJSValue(context))
            case FLOAT32ARRAY(x) => context.global["Float32Array"].asClass().new(context.arrayBuffer(x).toJSValue())
            case BIGINT(x) => context.bigint(x).toJSValue()
        }
    }
    public static func fromJSValue(context: JSContext, input: JSValue): ARK1 {

        if (input.isNull()) {
            return NULL
        }
        if (input.isNumber()) {
            return NUMBER(Float64.fromJSValue(context, input))
        }
        if (input.isString()) {
            return STRING(String.fromJSValue(context, input))
        }
        if (input.isBoolean()) {
            return BOOLEAN(Bool.fromJSValue(context, input))
        }
        if (instanceof(input, "Uint8Array")) {
            let jsArray: JSValue = context.global["Uint8Array"].asObject().callMethod("from", [input])
            return BYTEARRAY(fromJSArray<UInt8>(context, jsArray))
        }
        if (instanceof(input, "Float32Array")) {
            let jsArray: JSValue = context.global["Float32Array"].asObject().callMethod("from", [input])
            return FLOAT32ARRAY(fromJSArray<Float32>(context, jsArray))
        }
        if (input.isBigInt()) {
            return BIGINT(input.toBigInt())
        }
        throw Exception("unsupport type!")
    }
}
```

### Promise 类型

.d.ts 代码：

```typescript
typeReference21: Promise<T>;
```

生成的仓颉代码：

```cangjie
public var typeReference21: JSValue/* FIXME: `Promise<T>` */
```

### 交叉类型

.d.ts 代码：

```typescript
interface IntersectionTypes<U, T> {
  intersectionType: object & Record<U, T>;
}
```

当前类型不支持，会默认转换成 JSValue。

生成的仓颉代码：

```cangjie
/*interface IntersectionTypes {
    intersectionType: object & Record<U, T>;
    }*/

public open class IntersectionTypes<U, T> where U <: JSInteropType<U>, T <: JSInteropType<T> {
    public var intersectionType: JSValue/* FIXME: `object & HashMap<U, T>` */
    protected init(intersectionType: JSValue/* FIXME: `object & HashMap<U, T>` */) {
        this.intersectionType = intersectionType
    }

    public open func toJSValue(context: JSContext): JSValue {
        let obj = context.object()
        obj["intersectionType"] = intersectionType
        obj.toJSValue()
    }

    public static func fromJSValue(context: JSContext, input: JSValue): IntersectionTypes<U, T> {
        let obj = input.asObject()
        IntersectionTypes(
        obj["intersectionType"]
        )
    }
}
```

### 导入

- 目前导入会翻译，但是还是需要用户收到确认修改。

.d.ts 代码：

```typescript
import { a } from '@umeng/common';
import buffer from '@ohos.buffer';
import { e } from "../g/h";

import { MyStringEnum, MyNumericEnum } from './exportAlias'; // Type Imports
declare const value1: MyStringEnum;
declare const value2: MyNumericEnum;

import * as Inheritances from './inheritances'; // Module Import
declare function createSub(): Inheritances.SubClass;

import { ExportedInterface } from './exportAlias'; // Module Augmentation
declare module './exportAlias' {
    interface ExportedInterface {
        myOption?: string;
    }
}
```

生成的仓颉代码：

```cangjie
import ohos.ark_interop.*
import ohos.ark_interop_helper.*
import ohos.base.*
/***********IMPORT***********/
/*FIXME: Import details need to be verified and rewritten by user.*/
/*import { a } from '@umeng/common';*/

/*FIXME: Import details need to be verified and rewritten by user.*/
/*import buffer from '@ohos.buffer';*/

/*FIXME: Import details need to be verified and rewritten by user.*/
/*import { e } from "../g/h";*/

/*FIXME: Import details need to be verified and rewritten by user.*/
/*import { MyStringEnum, MyNumericEnum } from './exportAlias';*/

/*FIXME: Import details need to be verified and rewritten by user.*/
/*import * as Inheritances from './inheritances';*/

/*FIXME: Import details need to be verified and rewritten by user.*/
/*import { ExportedInterface } from './exportAlias';*/

/*

public const value1 = 0/* FIXME: Initialization is required */
*/
/*

public const value2 = 0/* FIXME: Initialization is required */
*/

/***********METHOD***********/
/**
     * @brief createSub(): Inheritances.SubClass
     */
public func createSub(): JSValue/* FIXME: `Inheritances.SubClass` */ {
    hmsGlobalApiCall < JSValue/* FIXME: `Inheritances.SubClass` */ >( "_ark_interop_api", "createSub", EMPTY_ARG) { ctx, info => info }
}

/*interface ExportedInterface {
    myOption?: String;
    }*/

public open class ExportedInterface {
    public var myOption: Option<String> = None
    protected init(myOption!: Option<String> = None) {
        this.myOption = myOption
    }

    public open func toJSValue(context: JSContext): JSValue {
        let obj = context.object()
        if (let Some(v) <- myOption) {
            obj["myOption"] = v.toJSValue(context)
        }
        obj.toJSValue()
    }

    public static func fromJSValue(context: JSContext, input: JSValue): ExportedInterface {
        let obj = input.asObject()
        ExportedInterface(
        myOption:
        if (obj["myOption"].isNull()) {
            None < String >
        } else {
            String.fromJSValue(context, obj["myOption"])
        }
        )
    }
}
```