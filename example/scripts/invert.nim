proc getText*(children: seq[float]): string =
  if children.len() == 0: return "Attach Card"
  var total: float
  for c in children:
    total += c
  
  total /= children.len().float
  total = 1.0 - total

  result = $(total * 100).int & "%"

proc getProgress*(children: seq[float]): float =
  if children.len() == 0: return 0

  for c in children:
    result += c

  result /= children.len().float

  result = 1.0 - result

proc pressKey*(data: string) =
   discard
