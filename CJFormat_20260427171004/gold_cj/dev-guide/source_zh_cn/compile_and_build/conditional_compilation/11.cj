//source.cj
@When[(test || feature == "lion") && !debug]
func fee() {
    println("feature lion")
}

main() {
    fee()
}
