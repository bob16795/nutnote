import hangover
import data
import math

type
  Camera* = object
    mapSize*: Point
    target*: Vector2
    position*: Vector2

proc update*(cam: var Camera, dt: float): Vector2 =
  var start = cam.position
  if dt >= CAM_SPEED:
    cam.position = cam.target
    return cam.position - start
  cam.position += (cam.target - cam.position) / CAM_SPEED * dt.float32
  return cam.position - start
