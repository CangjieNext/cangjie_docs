enum TimeUnit {
    Day | Month | Year
}

type Time = TimeUnit

var a = Time.Day
var b = Time.Month // Use type alias Time to access constructors in TimeUnit
