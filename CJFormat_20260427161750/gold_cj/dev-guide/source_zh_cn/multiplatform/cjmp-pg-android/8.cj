package cjworld

import interoplib.interop

public class IntFuncBox {
    private let _f: (Int) -> Int
    public init(f: (Int) -> Int) {
        _f = f
    }
    public func unbox(): (Int) -> Int {
        _f
    }
}
