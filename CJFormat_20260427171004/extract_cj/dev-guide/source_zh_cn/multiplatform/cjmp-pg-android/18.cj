package cjworld

import interoplib.interop.*

public class Composer<T, U, V> {
    public static func compose(f: (T) -> U, g: (U) -> V): (T) -> V {
        { t: T => g(f(t)) }
    }
}