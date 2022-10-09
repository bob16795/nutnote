import hangover
import strutils
import ../card
import ../data
import json
import nimscripter
import options
import oids
import os

type
  ScriptCard* = ref object of Card
    file: string
    inter: Interpreter

method pressKey*(c: ScriptCard, text: string) =
  c.inter.invoke(pressKey, text)
  
method drawText*(c: ScriptCard, f: Font, unit: float32) =
  var box = c.actBounds.scale(unit)
  f.draw(c.file, box.offset(newVector2(38 / 32 * unit, 6 / 32 * unit)).location, TEXT_COLOR, scale=ScaleFont(20 / 32 * unit))
  var y = 1
  for line in c.text.split("\n"):
    if y >= c.bounds.height.int:
      return
    var box = c.actBounds
    box = box.offset(newVector2(0, y)).scale(unit)
    f.draw(line, box.offset(newVector2(4 / 32 * unit, 6 / 32 * unit)).location, TEXT_COLOR, scale=ScaleFont(20 / 32 * unit))
    y += 1

method postUpdate*(c: ScriptCard, dt: float32) =
  var values: seq[float]
  for card in c.parents:
    values &= card.progress.float
  c.text = c.inter.invoke(getText, values, returnType = string)
  c.progress = c.inter.invoke(getProgress, values, returnType = float)

proc newScriptCard*(bounds: Rect, file: string, min: Point, icon: Sprite, oid = genOid()): ScriptCard =
  result = ScriptCard()
  result.id = oid
  result.icon = icon
  result.file = file.relativePath(getCurrentDir())
  result.minx = min.x.float32
  result.miny = min.y.float32

  result.target = bounds
  result.actBounds = bounds
  var script = loadScript(NimScriptPath(file), stdPath = getAppDir() / "stdlib")
  if script.isSome:
    result.inter = script.get()
  else:
    result.text = "Error loading"

method `$$`*(c: ScriptCard): JsonNode =
  return %*{
    "id": $c.id,
    "kind": "Script",
    "text": c.text,
    "file": c.file,
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
