import hangover
import data
import card

type
  Cursor* = object
    bounds: Rect
    target*: Rect
    pin*: bool

    resize*: bool
    resizing*: bool
    move*: bool

    wire*: bool
    wireCard*: Card

var
  curSprite*: UISprite
  resSprite*: UISprite
  curOffset*: float32

proc scale(r: Rect, scale: float32): Rect =
  result.size = r.size * scale
  result.location = r.location * scale

proc update*(c: var Cursor, dt: float32) =
  var
    p1 = c.bounds.location
    p2 = c.bounds.location + c.bounds.size
  let
    t1 = c.target.location
    t2 = c.target.location + c.target.size

  if dt >= CUR_SPEED:
    p1 = t1
    p2 = t2
  else:
    p1 += (t1 - p1) / CUR_SPEED * dt.float32
    p2 += (t2 - p2) / CUR_SPEED * dt.float32

  c.bounds.location = p1
  c.bounds.size = p2 - p1

proc setTarget*(c: var Cursor, target: Rect) =
  if c.pin: #and not c.resize:
    c.target.size = target.location - c.target.location + target.size
  else:
    c.target = target

proc draw*(c: Cursor, unit: float32) =
  var box = c.bounds.fix().scale(unit)
  box.location = box.location - newVector2(curOffset, curOffset)
  box.size = box.size + newVector2(curOffset, curOffset) * 2
  if c.resize:
    resSprite.draw(box, c=SEL_COLOR)
  else:
    curSprite.draw(box, c=SEL_COLOR)
