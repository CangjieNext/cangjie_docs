macro package define

import std.ast.*

public macro linq(input: Tokens) {
    let syntaxMsg = "Syntax is \"from <attrib> in <table> where <cond> select <expr>\""
    if (input.size == 0 || input[0].value != "from") {
        diagReport(DiagReportLevel.ERROR, input[0..1], syntaxMsg,
                   "Expected keyword \"from\" here.")
    }
    if (input.size <= 1 || input[1].kind != TokenKind.IDENTIFIER) {
        diagReport(DiagReportLevel.ERROR, input[1..2], syntaxMsg,
                   "Expected identifier here.")
    }
    let attribute = input[1]
    if (input.size <= 2 || input[2].value != "in") {
        diagReport(DiagReportLevel.ERROR, input[2..3], syntaxMsg,
                   "Expected keyword \"in\" here.")
    }
    var index: Int64 = 3
    let (table, nextIndex) = parseExprFragment(input, startFrom: index)
    if (nextIndex == input.size || input[nextIndex].value != "where") {
        diagReport(DiagReportLevel.ERROR, input[nextIndex..nextIndex+1], syntaxMsg,
                   "Expected keyword \"where\" here.")
    }
    index = nextIndex + 1  // Skip 'where'
    let (cond, nextIndex2) = parseExprFragment(input, startFrom: index)
    if (nextIndex2 == input.size || input[nextIndex2].value != "select") {
        diagReport(DiagReportLevel.ERROR, input[nextIndex2..nextIndex2+1], syntaxMsg,
                   "Expected keyword \"select\" here.")
    }
    index = nextIndex2 + 1  // Skip 'select'
    let (expr, nextIndex3) = parseExprFragment(input, startFrom: index)

    return quote(
        for ($(attribute) in $(table)) {
            if ($(cond)) {
                println($(expr))
            }
        }
    )
}