@When[env == "ohos"]
var env = "ohos"
@When[env != "ohos"]
var env = "other"

main() {
    println(env)
}
