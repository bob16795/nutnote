import hangover
import cfg
import data
import tables
import times
import os

type
  stLocation* = enum
    stPrompt
    stLeft
    stCenter
    stRight

var
  statusSprite*: Sprite
  statusVals*: array[stLocation, string]

  statusPrompt*: bool
  promptStart*: string

proc updateStatus*(mode: kbMode, openFile: string) =
  for v in stLocation:
    if v == stPrompt and statusPrompt: continue
    statusVals[v] = ""

  statusVals[stLeft] &= mode.name
  statusVals[stCenter] &= getClockStr()
  if openFile == "": statusVals[stRight] &= "No File"
  else: statusVals[stRight] &= openFile.extractFilename()

proc drawStatus*(uiFont: Font, size: Vector2, height: float32, bgSprite: var Sprite, bgColor, statusColor: Color) =
  if height > 0:
    var tmpVals = statusVals

    if statusPrompt:
      tmpVals[stLeft] = promptStart & tmpVals[stPrompt]

    bgSprite.draw(newRect(0, size.y - height, size.x, height).offset(textureOffset), color=bgColor)
    statusSprite.draw(newRect(0, size.y - height, size.x, height).offset(textureOffset), color=statusColor)

    LOG_TRACE "nutnote->status", tmpVals

    var fontSize = (height * 0.75) / (FONT_SIZE * 2)

    var statusSizes: array[stLocation, Vector2]
    statusSizes[stLeft] = uiFont.sizeText(tmpVals[stLeft], scale=fontSize)
    statusSizes[stCenter] = uiFont.sizeText(tmpVals[stCenter], scale=fontSize)
    statusSizes[stRight] = uiFont.sizeText(tmpVals[stRight], scale=fontSize)

    var y = size.y - height * 0.875

    uiFont.draw(tmpVals[stLeft], newVector2(10, y) + textureOffset, newColor(255, 255, 255), scale = fontSize)
    uiFont.draw(tmpVals[stCenter], newVector2((size.x - statusSizes[stCenter].x) / 2, y) + textureOffset, newColor(255, 255, 255), scale = fontSize)
    uiFont.draw(tmpVals[stRight], newVector2(size.x - 10 - statusSizes[stRight].x, y) + textureOffset, newColor(255, 255, 255), scale = fontSize)

proc prompt*(p: string) =
  LOG_TRACE "nutnote->prompt", "Start"
  statusPrompt = true
  promptStart = p
  var tmp = ""
  sendEvent(EVENT_START_LINE_ENTER, nil)
  sendEvent(EVENT_SET_LINE_TEXT, addr tmp)

proc endPrompt*(): string =
  statusPrompt = false
  sendEvent(EVENT_STOP_LINE_ENTER, nil)
  return statusVals[stPrompt]
