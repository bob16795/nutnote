import hangover
import strutils
import json
import ../card
import ../data
import oids
import os

type
  ImageCard* = ref object of Card
    file*: string
    texture: Texture

method pressKey*(c: ImageCard, text: string) =
  c.text = text
  
method drawText*(c: ImageCard, f: Font, unit: float32, textColor: Color) =
  var y = 0
  for line in c.text.split("\n"):
    if y >= c.bounds.height.int:
      return
    var box = c.actBounds
    if y == 0:
      box = box.offset(newVector2(1, 0))
    box = box.offset(newVector2(0, y)).scale(unit)
    f.draw(line, box.offset(newVector2(4 / 32 * unit, 6 / 32 * unit)).location, textColor, scale=ScaleFont(20 / 32 * unit))
    y += 1
  var box = c.actBounds
  box.height -= 1
  box.y += 1
  box = box.scale(unit)
  box.x += unit / 8
  box.y += unit / 8
  box.width -= unit / 4
  box.height -= unit / 4
  c.texture.draw(newRect(0, 0, 1, 1), box)

method postUpdate*(c: ImageCard, dt: float32) =
  c.progress = 1

proc newImageCard*(bounds: Rect, file: string, text: string, min: Point, icon: Sprite, oid: Oid = Oid()): ImageCard =
  result = ImageCard()
  if oid == Oid():
    result.id = genOid()
    result.icon = icon
    result.file = file.relativePath(getCurrentDir())
    result.text = text
    result.texture = newTexture(file)
    var b = bounds
    var h = (bounds.width / result.texture.size.x * result.texture.size.y).int
    b.height = h.float32 + 1
    result.minx = min.x.float32
    result.miny = min.x.float32 / result.texture.size.x * result.texture.size.x
    result.miny += 1

    result.target = b
    result.actBounds = b
  else:
    result.id = oid
    result.icon = icon
    result.file = file.relativePath(getCurrentDir())
    result.texture = newTexture(file)
    result.minx = min.x.float32
    result.miny = min.y.float32

    result.target = bounds
    result.actBounds = bounds

method `$$`*(c: ImageCard): JsonNode =
  return %*{
    "id": $c.id,
    "kind": "Image",
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
