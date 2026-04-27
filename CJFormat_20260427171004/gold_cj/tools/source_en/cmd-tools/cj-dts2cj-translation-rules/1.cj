import ohos.ark_interop.*
import ohos.ark_interop_helper.*
import ohos.base.*

/***********METHOD***********/
/**
 * @brief greeter(fn: (a: string) => void): void
 */
public func greeter(fn: (a: String) -> Unit): Unit {
    hmsGlobalApiCall<Unit>("_ark_interop_api", "greeter", {
        ctx => [ctx.function(
            {
                ctx, info =>
                    let p0 = String.fromJSValue(ctx, info[0])
                    fn(p0)
                    ctx.undefined().toJSValue()
            }
        ).toJSValue()]
    })
}

/**
 * @brief printToConsole(s: string): void
 */
public func printToConsole(s: String): Unit {
    hmsGlobalApiCall<Unit>("_ark_interop_api", "printToConsole", {ctx => [s.toJSValue(ctx)]})
}
