import hangover
import strutils
import json
import ../card
import ../data
import oids

type
  NoteCard* = ref object of Card

method pressKey*(c: NoteCard, text: string) =
  c.text = text
  
method drawText*(c: NoteCard, f: Font, unit: float32) =
  var y = 0
  for line in c.text.split("\n"):
    if y >= c.bounds.height.int:
      return
    var box = c.actBounds
    if y == 0:
      box = box.offset(newVector2(1, 0))
    box = box.offset(newVector2(0, y)).scale(unit)
    f.draw(line, box.offset(newVector2(4 / 32 * unit, 6 / 32 * unit)).location.toPoint(), TEXT_COLOR, scale=ScaleFont(20 / 32 * unit))
    y += 1

method postUpdate*(c: NoteCard, dt: float32) =
  c.progress = 1

method `$$`*(c: NoteCard): JsonNode =
  return %*{
    "id": $c.id,
    "kind": "Note",
    "text": c.text,
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
