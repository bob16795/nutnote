import parseutils
var val: string

proc getText*(children: seq[float]): string =
  var total: float
  discard parseFloat(val, total)
  result = val & ": " & $(total * 100).int & "%"

proc getProgress*(children: seq[float]): float =
  discard parseFloat(val, result)

proc pressKey*(data: string) =
   val = data
