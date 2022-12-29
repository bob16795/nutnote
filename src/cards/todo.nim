import hangover
import strutils
import json
import ../card
import ../data
import oids

type
  TodoCard* = ref object of Card
    done*: bool

var
  checkSprite*: Sprite

method pressKey*(c: TodoCard, text: string) =
  c.text = text
  
method drawText*(c: TodoCard, f: Font, unit: float32, textColor: Color) =
  var y = 0
  for line in c.text.split("\n"):
    if y >= c.bounds.height.int:
      break
    var box = c.actBounds
    if y == 0:
      box = box.offset(newVector2(1, 0))
    box = box.offset(newVector2(0, y)).scale(unit)
    f.draw(line, box.offset(newVector2(4 / 32 * unit, 6 / 32 * unit)).location, textColor, scale=ScaleFont(20 / 32 * unit))
    y += 1
  if c.progress == 1:
    checkSprite.draw(newRect(c.actBounds.location * unit, 24 / 32 * unit, 24 / 32 * unit).offset(newVector2(4 / 32 * unit, 4 / 32 * unit)), color=ICON_COLOR)

method postUpdate*(c: TodoCard, dt: float32) =
  if c.parents == @[]:
    c.progress = if c.done: 1.0 else: 0.0
  else:
    c.progress = 0
    for p in c.parents:
      c.progress += p.progress
    c.progress /= c.parents.len().float32

method `$$`*(c: TodoCard): JsonNode =
  return %*{
    "id": $c.id,
    "kind": "Todo",
    "text": c.text,
    "done": c.done,
    "location": {
      "x": c.bounds.x,
      "y": c.bounds.y,
      "w": c.bounds.width,
      "h": c.bounds.height,
    },
    "min": {
      "x": c.minx,
      "y": c.miny,
    },
  }
