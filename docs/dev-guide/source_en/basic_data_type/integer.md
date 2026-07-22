# Integer Types

Integer types are divided into signed integer types and unsigned integer types.

**Signed integer types** include `Int8`, `Int16`, `Int32`, `Int64`, and `IntNative`, which are used to represent signed integer values with encoding lengths of `8-bit`, `16-bit`, `32-bit`, `64-bit`, and platform-dependent sizes, respectively.

**Unsigned integer types** include `UInt8`, `UInt16`, `UInt32`, `UInt64`, and `UIntNative`, which are used to represent unsigned integer values with encoding lengths of `8-bit`, `16-bit`, `32-bit`, `64-bit`, and platform-dependent sizes, respectively.

For a signed integer type with an encoding length of `N`, its representable range is: $-2^{N-1} \sim 2^{N-1}-1$; for an unsigned integer type with an encoding length of `N`, its representable range is: $0 \sim 2^{N}-1$. The following table lists the representable ranges of all integer types:

| Type        | Representable Range                                                                                |
|:-----------|:------------------------------------------------------------------------------------|
| Int8       | $-2^7 \sim 2^7-1 (-128 \sim 127)$                                                   |
| Int16      | $-2^{15} \sim 2^{15}-1 (-32,768 \sim 32,767)$                                       |
| Int32      | $-2^{31} \sim 2^{31}-1 (-2,147,483,648 \sim 2,147,483,647)$                         |
| Int64      | $-2^{63} \sim 2^{63}-1 (-9,223,372,036,854,775,808 \sim 9,223,372,036,854,775,807)$ |
| IntNative  | platform dependent                                                                  |
| UInt8      | $0 \sim 2^8-1 (0 \sim 255)$                                                         |
| UInt16     | $0 \sim 2^{16}-1 (0 \sim 65,535)$                                                   |
| UInt32     | $0 \sim 2^{32}-1 (0 \sim 4,294,967,295)$                                            |
| UInt64     | $0 \sim 2^{64}-1 (0 \sim 18,446,744,073,709,551,615)$                               |
| UIntNative | platform dependent                                                                  |

The choice of which integer type to use in a program depends on the nature and range of the integers to be processed. When `Int64` is suitable, it is preferred because its representable range is sufficiently large, and [integer literals](./integer.md#integer-literals) default to `Int64` type in the absence of type context, avoiding unnecessary type conversions. Additionally, the Cangjie programming language provides `IntNative` and `UIntNative` as signed and unsigned integer types, respectively, with bit widths consistent with the current system. This means their sizes depend on the platform they run on, allowing them to automatically adapt to the system's bit width in cross-platform development.

## Integer Literals

Integer literals can be represented in 4 radix forms: binary (with `0b` or `0B` prefix), octal (with `0o` or `0O` prefix), decimal (no prefix), and hexadecimal (with `0x` or `0X` prefix). For example, the decimal number `24` can be represented as `0b00011000` (or `0B00011000`) in binary, `0o30` (or `0O30`) in octal, and `0x18` (or `0X18`) in hexadecimal.

In any radix representation, underscores `_` can be used as separators to improve readability, such as `0b0001_1000`.

If the value of an integer literal exceeds the representable range of the required integer type in the context, the compiler will report an error.

<!-- compile.error -->

```cangjie
let x: Int8 = 128 // Error, 128 out of the range of Int8
let y: UInt8 = 256 // Error, 256 out of the range of UInt8
let z: Int32 = 0x8000_0000 // Error, 0x8000_0000 out of the range of Int32
```

When using integer literals, suffixes can be added to explicitly specify the type of the literal. The correspondence between suffixes and types is as follows:

|  Suffix  | Type   |  Suffix  | Type    |
| :----- | :---- | :----  | :----- |
| i8     | Int8  | u8     | UInt8  |
| i16    | Int16 | u16    | UInt16 |
| i32    | Int32 | u32    | UInt32 |
| i64    | Int64 | u64    | UInt64 |

Integer literals with suffixes can be used in the following ways:

<!-- compile -->

```cangjie
var x = 100i8 // x is 100 with type Int8
var y = 0x10u64 // y is 16 with type UInt64
var z = 0o432i32 // z is 282 with type Int32
```

## Character Byte Literals

The Cangjie programming language supports character byte literals to facilitate the representation of `UInt8` values using ASCII codes. A character byte literal consists of the character `b`, a pair of single quotes, and an `ASCII` character, for example:

<!-- compile -->

```cangjie
var a = b'x'                    // a is 120 with type UInt8
var b = b'\n'                   // b is 10 with type UInt8
var c = b'\u{78}'               // c is 120 with type UInt8
c = b'\u{90}' - b'\u{66}' + c   // c is 162 with type UInt8
```

`b'x'` represents a literal value of type `UInt8` with a value of 120. Additionally, the escape form `b'\u{78}'` can be used to represent a literal value of type `UInt8` with a hexadecimal value of 0x78 or a decimal value of 120. Note that the `\u` escape sequence can contain at most two hexadecimal digits, and the value must be less than 256 (in decimal).

## Operations Supported by Integer Types

Integer types natively support the following operators: arithmetic operators, bitwise operators, relational operators, increment and decrement operators, and compound assignment operators. The precedence of these operators can be found in the [Operators](../Appendix/operator.md) section of the appendix.

Conversions are allowed between integer types, as well as between integer and floating-point types. Integer types can also be converted to character types. For specific syntax and rules on type conversions, refer to [Numeric Type Conversions](#numeric-type-conversions).

> **Note:**
>
> The operations mentioned in this chapter refer to those supported natively, without [operator overloading](../function/operator_overloading.md).

## Numeric Type Conversions

For numeric types (including: `Int8`, `Int16`, `Int32`, `Int64`, `UInt8`, `UInt16`, `UInt32`, `UInt64`, `Float16`, `Float32`, `Float64`), Cangjie supports using the `T(e)` syntax to obtain a value equal to `e` with type `T`. Here, the expression `e` and type `T` can be any of the aforementioned numeric types.

The following example demonstrates conversions between integer types, conversions between integer and floating-point types, and conversions between floating-point types:

<!-- verify -->

```cangjie
main() {
    // Conversions between integer types
    let a: Int8 = 10
    let b: Int16 = 20
    let r1 = Int16(a)
    println("The type of r1 is 'Int16', and r1 = ${r1}")
    let r2 = Int8(b)
    println("The type of r2 is 'Int8', and r2 = ${r2}")

    // Conversions between integer and floating-point types
    let c: Int64 = 1024
    let d: Float64 = 1024.1024
    let r3 = Float64(c)
    println("The type of r3 is 'Float64', and r3 = ${r3}")
    let r4 = Int64(d)
    println("The type of r4 is 'Int64', and r4 = ${r4}")

    // Conversions between floating-point types
    let e: Float32 = 1.0
    let f: Float64 = 1.123456789
    let r5 = Float64(e)
    println("The type of r5 is 'Float64', and r5 = ${r5}")
    let r6 = Float32(f)
    println("The type of r6 is 'Float32', and r6 = ${r6}")
}
```

The execution result of the above code is:

```text
The type of r1 is 'Int16', and r1 = 10
The type of r2 is 'Int8', and r2 = 20
The type of r3 is 'Float64', and r3 = 1024.000000
The type of r4 is 'Int64', and r4 = 1024
The type of r5 is 'Float64', and r5 = 1.000000
The type of r6 is 'Float32', and r6 = 1.123457
```

> **Note:**
>
> Overflow may occur during type conversion. If the overflow can be detected by the compiler in advance, the compiler will directly report an error. Otherwise, an exception will be thrown according to the default overflow policy.

## Conversion from `Rune` to `UInt32` and from Integer Types to `Rune`

Conversion from `Rune` to `UInt32` uses the `UInt32(e)` syntax, where `e` is a `Rune`-type expression. The result of `UInt32(e)` is the `UInt32`-type integer value corresponding to the Unicode scalar value of `e`.

Conversion from integer types to `Rune` uses the `Rune(num)` syntax, where `num` can be of any integer type. Only when the value of `num` falls within `[0x0000, 0xD7FF]` or `[0xE000, 0x10FFFF]` (i.e., Unicode scalar value range), the corresponding character represented by the Unicode scalar value is returned. Otherwise, a compilation error will occur (if the value of `num` can be determined at compile time) or an exception will be thrown at runtime.

The following example demonstrates type conversion between `Rune` and `UInt32`:

<!-- verify -->

```cangjie
main() {
    let x: Rune = 'a'
    let y: UInt32 = 65
    let r1 = UInt32(x)
    let r2 = Rune(y)
    println("The type of r1 is 'UInt32', and r1 = ${r1}")
    println("The type of r2 is 'Rune', and r2 = ${r2}")
}
```

The execution result of the above code is:

```text
The type of r1 is 'UInt32', and r1 = 97
The type of r2 is 'Rune', and r2 = A
```