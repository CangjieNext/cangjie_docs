import std.process.*

func stagePreBuild(): Int64 {
    println("PRE-BUILD")
    0
}

func stagePostBuild(): Int64 {
    println("POST-BUILD")
    0
}

main(): Int64 {
    match (Process.current.arguments[0]) {
        case "pre-build" => stagePreBuild()
        case "post-build" => stagePostBuild()
        case _ => 0
    }
}