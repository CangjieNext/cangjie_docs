/**
  * @brief testMultiGenericT(t: T, m: M): T
  */
public func testMultiGenericT < T, M >(t: T, m: M): T where T <: JSInteropType<T>, M <: JSInteropType<M> {
    hmsGlobalApiCall < T >( "my_module_genericFunction", "testMultiGenericT", { ctx =>[t.toJSValue(ctx), m.toJSValue(ctx)] }) {
        ctx, info => T.fromJSValue(ctx, info)
    }
}
