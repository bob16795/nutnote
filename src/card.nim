import hangover
import data
import json
import oids

var
  gridSprite*: Sprite
  bgSprite*: Sprite

  selSprite*: UISprite
  boxSprite*: UISprite
  selOffset*: float32

type
  Card* = ref object of RootObj
    id*: Oid
    actBounds*: Rect
    target*: Rect
    focused*: bool
    selected*: bool
    progress*: float32
    progressDisp*: float32
    minx*, miny*: float32
    text*: string
    icon*: Sprite

    parents*: seq[Card]

proc scale*(r: Rect, scale: float32): Rect =
  result.size = r.size * scale
  result.location = r.location * scale

proc `bounds=`*(c: Card, r: Rect) =
  c.target = r

template bounds*(c: Card): Rect =
  c.target

method postUpdate*(c: Card, dt: float32) =
  discard

proc update*(c: Card, dt: float32) =
  var
    p1 = c.actBounds.location
    p2 = c.actBounds.location + c.actBounds.size
  let
    t1 = c.target.location
    t2 = c.target.location + c.target.size

  if dt >= CUR_SPEED:
    p1 = t1
    p2 = t2
    c.progressDisp = c.progress
  else:
    p1 += (t1 - p1) / CUR_SPEED * dt.float32
    p2 += (t2 - p2) / CUR_SPEED * dt.float32
    c.progressDisp += (c.progress - c.progressDisp) / CUR_SPEED * dt.float32

  c.actBounds.location = p1
  c.actBounds.size = p2 - p1
  c.postUpdate(dt)

method draw*(c: Card, unit: float32) {.base.} =
  var box = c.actBounds.scale(unit)
  bgSprite.draw(box, color=CARD_COLOR)
  var b2 = box
  b2.width *= c.progressDisp.clamp(0, 1)
  bgSprite.draw(b2, color=PROG_COLOR)
  if box.height > unit:
    var botBox = box
    botBox.height -= unit
    botBox.y += unit
    boxSprite.draw(botBox, c=BORDER_COLOR)
  boxSprite.draw(box, c=BORDER_COLOR)
  
  c.icon.draw(newRect(box.location, 24 / 32 * unit, 24 / 32 * unit).offset(newVector2(4 / 32 * unit, 4 / 32 * unit)), color=ICON_COLOR)


method pressKey*(c: Card, text: string) =
  c.text = text
  
method drawText*(c: Card, f: Font, unit: float32) {.base.} =
  var box = c.actBounds.scale(unit)
  f.draw(c.text, box.offset(newVector2(0, 6)).location.toPoint(), TEXT_COLOR, scale=ScaleFont(20 / 32 * unit))

proc drawSel*(c: Card, unit: float32, curMode: int) =
  case curMode
  of 0:
    if c.selected:
      var box = c.actBounds.scale(unit)
      box.location = box.location - newVector2(selOffset, selOffset)
      box.size = box.size + newVector2(selOffset, selOffset) * 2

      selSprite.draw(box, c=SEL_COLOR)
  of 1:
    if c.selected:
      var box = c.actBounds.scale(unit)
      box.location = box.location - newVector2(selOffset, selOffset)
      box.size = box.size + newVector2(selOffset, selOffset) * 2

      selSprite.draw(box, c=EDIT_COLOR)
  of 2:
    if c.selected:
      var box = c.actBounds.scale(unit)
      box.location = box.location - newVector2(selOffset, selOffset)
      box.size = box.size + newVector2(selOffset, selOffset) * 2

      selSprite.draw(box, c=WIRE_COLOR)
  else:
    discard

method `$$`*(c: Card): JsonNode =
  return %*{
    "id": c.id,
    "kind": "Card",
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
