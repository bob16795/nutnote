import parseutils
var val: string

proc getText*(children: seq[float]): string =
  if children.len() == 0:
    var total: float
    discard parseFloat(val, total)
    result = val & ": " & $(total * 100).int & "%"
  else:
    result = $(children[0] * 100).int & "%"

proc getProgress*(children: seq[float]): float =
  if children.len() == 0:
    discard parseFloat(val, result)
  else:
    return children[0] 

proc pressKey*(data: string) =
   val = data
