import define.*

main() {
    @linq(from x in 1..=10 where x % 2 == 1 select x * x)
}
