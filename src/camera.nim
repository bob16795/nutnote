import hangover
import data
import math

type
  Camera* = object
    mapSize*: Point
    target*: Vector2
    pos*: Vector2
    zoom*: float32
    zoomTrg*: float32
    size*: Vector2

proc position*(cam: var Camera): Vector2 =
  return (cam.pos - (cam.size / (32 * cam.zoom) / 8))

proc update*(cam: var Camera, size: Vector2, dt: float): Vector2 =
  cam.size = size
  var start = cam.pos
  if dt >= CAM_SPEED:
    cam.pos = cam.target
    return cam.pos - start
  var trg = cam.target
  cam.pos += (trg - cam.pos) / CAM_SPEED * dt.float32
  return cam.pos - start
