import hangover
import content/files
import src/cards/todo
import src/cards/note
import src/cards/script
import src/cards/image
import src/textureData
import src/wires
import src/saving
import src/camera as cam
import src/cursor as cur
import src/config
import src/data
import src/card
import src/undo
import oids

import native_dialogs

import segfaults
import random
import sugar
import sequtils
import tables
import math
import os

Game:
  var
    bg: Color
    textures: TextureAtlas
    camera: Camera
    
    size: Point
    timer: float32

    cards: seq[Card]
    cursor: Cursor

    mousePos: Vector2
    dragStart: Vector2
    dragCamStart: Vector2
    resizeStart: Rect

    moveStart: Vector2
  
    startText: string

    drag: bool
    uiFont: Font

    ctrlMod: bool
    shiftMod: bool

    curMode: kbMode

    icons: Table[string, Sprite]

    fullscreen: bool

  template unit: untyped = camera.zoom * 32

  proc keyDownEvent(data: pointer): bool =
    var key = cast[ptr Key](data)[]

    case curMode:
      of kbNormal:
        case key
        of keyLeftControl, keyRightControl:
          ctrlMod = true
        of keyLeftShift, keyRightShift:
          shiftMod = true
        of keyW:
          camera.target += newVector2(0, -4)
        of keyA:
          if not ctrlMod:
            camera.target += newVector2(-4, 0)
          else:
            for c in cards:
              c.selected = not shiftMod
        of Key.keyS:
          if ctrlMod:
            saveCards(camera, cards, shiftMod)
          else:
            camera.target += newVector2(0, 4)
        of keyD:
          camera.target += newVector2(4, 0)
        of keyO:
          if ctrlMod:
            openFile(camera, cards, icons)
        of keyDelete:
          var delete = cards
          delete.keepItIf(it.selected)
          if delete != @[]:
            cards.keepItIf(not it.selected)
            for c in cards:
              c.parents.keepItIf(not it.selected)
            hist.addAction(Action(kind: akDelete, delCards: delete))
        of keyZ:
          if ctrlMod:
            if shiftMod: hist.redo(cards)
            else: hist.undo(cards)
        of keyY:
          if ctrlMod:
            hist.redo(cards)
        of keyV:
          curMode = kbWire
        of keyE:
          for c in cards:
            if curMode == kbEdit:
              c.selected = false
            if c.selected:
              sendEvent(EVENT_START_LINE_ENTER, nil)
              sendEvent(EVENT_SET_LINE_TEXT, addr c.text)
              startText = c.text
              curMode = kbEdit
        of keyF11:
          fullscreen = not fullscreen
        of keyR:
          for c in cards:
            if curMode == kbEdit:
              c.selected = false
            if c.selected:
              c.text = ""
              sendEvent(EVENT_START_LINE_ENTER, nil)
              sendEvent(EVENT_SET_LINE_TEXT, addr c.text)
              startText = ""
              curMode = kbEdit
        of keySpace:
          for c in cards:
            if c.selected:
              try:
                c.TodoCard.done = not c.TodoCard.done
              except:
                discard
        else: discard
      of kbEdit:
        case key
        of keyEnter:
          for c in cards:
            if c.selected:
              var data = c.text & "\n"
              c.pressKey(data)
              sendEvent(EVENT_SET_LINE_TEXT, addr data)
        of keyEscape:
          curMode = kbNormal
          sendEvent(EVENT_STOP_LINE_ENTER, nil)
          for c in cards:
            if c.selected:
              hist.addAction(Action(kind: akChange, changeBefore: startText, changeAfter: c.text, changeCard: c))
          return
        of keyLeftControl, keyRightControl:
          ctrlMod = true
        of keyLeftShift, keyRightShift:
          shiftMod = true
        else: discard
      of kbWire:
        case key
        of keyEscape:
          curMode = kbNormal
        else: discard
    var pos = [mousePos.x.float64 * unit, mousePos.y.float64 * unit]
    sendEvent(EVENT_MOUSE_MOVE, addr pos)

  proc lineEnterEvent(data: pointer): bool =
    for c in cards:
      if c.selected:
        c.pressKey(cast[ptr string](data)[])
  
  proc keyUpEvent(data: pointer): bool =
    var key = cast[ptr Key](data)[]
    case key
    of keyLeftControl, keyRightControl:
      ctrlMod = false
    of keyLeftShift, keyRightShift:
      shiftMod = false
    else: discard
    var pos = [mousePos.x.float64 * unit, mousePos.y.float64 * unit]
    sendEvent(EVENT_MOUSE_MOVE, addr pos)

  proc resizeEvent(data: pointer): bool =
    var size_d = cast[ptr tuple[w, h: int32]](data)[]

    size.x = size_d.w
    size.y = size_d.h

  proc mousePressEvent(data: pointer): bool =
    var btn = cast[ptr int](data)[]
    if curMode == kbEdit:
      curMode = kbNormal
      sendEvent(EVENT_STOP_LINE_ENTER, nil)
      for c in cards:
        if c.selected:
          hist.addAction(Action(kind: akChange, changeBefore: startText, changeAfter: c.text, changeCard: c))
    case btn
    of 0:
      if not cursor.resize:
        for c in cards:
          c.selected = c.focused
        for c in cards:
          if c.selected and c.focused:
            moveStart = mousePos
            cursor.move = true
            resizeStart = c.bounds
            return
      else:
        for c in cards:
          if c.focused:
            resizeStart = c.bounds
      cursor.pin = true
    of 1:
      for c in cards:
        if c.focused:
          cursor.wire = true
          cursor.wireCard = c
          return
      var bnds = newRect(((mousePos - newVector2(0.5, 0.5)).toPoint()).toVector2(), 10, 1)
      var card: Card
      if shiftMod:
        card = NoteCard(target: bnds, actBounds: bnds, text: "Note Card", minx: 5, miny: 1, icon: icons["Note"], id: genOid())
      elif ctrlMod:
        bnds.height = 2
        var path = callDialogFileOpen("Select File")
        if path == "": return
        case path.splitFile().ext
        of ".nim":
          card = newScriptCard(bnds, path, newPoint(5, 2), icons["Script"])
        of ".png":
          card = newImageCard(bnds, path, newPoint(5, 2), icons["Image"])
        else:
          return
      else:
        card = TodoCard(target: bnds, actBounds: bnds, text: "Todo Card", minx: 5, miny: 1, icon: icons["Todo"], id: genOid())
      hist.addAction(Action(kind: akAdd, addCard: card))
      cards &= card
    of 2:
      drag = true
      dragStart = mousePos
      dragCamStart = camera.target
    else: discard

  proc mouseReleaseEvent(data: pointer): bool =
    var btn = cast[ptr int](data)[]
    case btn
    of 0:
      if cursor.move:
        for c in cards:
          if c.focused and c.selected:
            hist.addAction(Action(kind: akResize, startSize: resizeStart, endSize: c.bounds, resCard: c))
        cursor.move = false
      cursor.pin = false
      if cursor.resize:
        for c in cards:
          if c.focused:
            hist.addAction(Action(kind: akResize, startSize: resizeStart, endSize: c.bounds, resCard: c))
      var pos = [mousePos.x.float64 * unit, mousePos.y.float64 * unit]
      sendEvent(EVENT_MOUSE_MOVE, addr pos)
    of 1:
      if cursor.wire:
        for c in cards:
          if c.focused:
            if c == cursor.wireCard: continue
            if cursor.wireCard in c.parents:
              c.parents.keepItIf(it != cursor.wireCard)
              hist.addAction(Action(kind: akUnwire, wireStart: cursor.wireCard, wireEnd: c))
            else:
              c.parents &= cursor.wireCard
              hist.addAction(Action(kind: akWire, wireStart: cursor.wireCard, wireEnd: c))
        cursor.wire = false
    of 2:
      drag = false
    else: discard

  proc mouseScrollEvent(data: pointer): bool =
    var pos = cast[ptr tuple[x, y: float64]](data)[]
    camera.zoomTrg += pos.x * 10
    camera.zoomTrg = clamp(camera.zoomTrg, 0.25, 2.5)

  proc mouseMoveEvent(data: pointer): bool =
    var pos_d = cast[ptr tuple[x, y: float64]](data)[]
    var target: Rect

    mousePos = newVector2(pos_d.x.float32 / unit, pos_d.y.float32 / unit)

    target.location = ((mousePos - newVector2(0.5, 0.5)).toPoint()).toVector2()
    target.size = newVector2(1, 1)
  
    cursor.setTarget(target)

    target = cursor.target.fix()
    
    var noresize: bool = true

    for c in cards:
      if c.selected and cursor.move:
        c.bounds.location = resizeStart.location - (moveStart - mousePos).toPoint().toVector2()
        if not cursor.pin:
          cursor.target = c.bounds
        return
      if c.focused and cursor.resize and cursor.pin:
        var trg = target.location + target.size - c.bounds.location
        if trg.x < c.minx:
          trg.x = c.minx
        if trg.y < c.miny:
          trg.y = c.miny
        cursor.target = newRect(c.bounds.location + c.bounds.size - newVector2(1, 1), 1, 1)
        c.bounds.size = trg
        return
      c.focused = false
      if cursor.pin:
        c.selected = false
      if c.bounds in target:
        var resizeBounds = newRect(c.bounds.location + c.bounds.size - newVector2(1, 1), 1, 1)
        if resizeBounds.location == target.location and not cursor.pin:
          cursor.resize = true
          c.focused = true
          noresize = false
        else:
          if cursor.pin:
            c.selected = true 
          else:
            c.focused = true
    
    if noresize:
      cursor.resize = false

    for c in cards:
      if c.focused:
        if not cursor.pin:
          cursor.target = c.bounds
        return

  proc drawLoading(pc: float32, loadStatus: string, ctx: GraphicsContext) =
    clearBuffer(ctx, BG_COLOR)

  proc toGrid(pos: float32): int =
    return (pos / 4).int - 1

  proc Setup(): AppData =
    result = newAppData()
    result.name = "NutNote"
    result.aa = 4

  proc Initialize(ctx: var GraphicsContext) =
    template loadAtlas(name: string, file: string) =
      textures &= newTextureDataMem(file.res.getPointer(), file.res.size.cint, name)

    uiFont = newFont(getAppDir() & "/font.ttf", FONT_SIZE * 2)
    
    textures = newTextureAtlas()
    loadAtlas("8x", "8x.png")
    loadAtlas("32x", "32x.png")
    textures.pack()

    bgSprite = newSprite(textures["8x"], Sprite8x(0, 2))
    gridSprite = newSprite(textures["32x"], Sprite32x(0, 0))
    selSprite = newUISprite(textures["8x"], Sprite8x(0, 1), Center8x(0, 1, 3, 3, 2, 2)).scale(Scale8x(32))
    curSprite = newUISprite(textures["8x"], Sprite8x(0, 0), Center8x(0, 0, 3, 3, 2, 2)).scale(Scale8x(32))
    resSprite = newUISprite(textures["8x"], Sprite8x(0, 6), Center8x(0, 6, 0, 0, 1, 1)).scale(Scale8x(32))
    boxSprite = newUISprite(textures["8x"], Sprite8x(0, 3), Center8x(0, 3, 1, 1, 2, 2)).scale(Scale8x(16))
    checkSprite = newUISprite(textures["8x"], Sprite8x(0, 5), Center8x(0, 5, 1, 1, 6, 6)).scale(Scale8x(16))
    icons["Todo"] = newSprite(textures["8x"], Sprite8x(0, 5))
    icons["Script"] = newSprite(textures["8x"], Sprite8x(0, 7))
    icons["Image"] = newSprite(textures["8x"], Sprite8x(0, 10))
    icons["Note"] = newSprite(textures["8x"], Sprite8x(0, 9))

    
    size.x = 600
    size.y = 400
    createListener(EVENT_RESIZE, resizeEvent)
    createListener(EVENT_MOUSE_SCROLL, mouseScrollEvent)
    createListener(EVENT_PRESS_KEY, keyDownEvent)
    createListener(EVENT_RELEASE_KEY, keyUpEvent)
    createListener(EVENT_MOUSE_MOVE, mouseMoveEvent)
    createListener(EVENT_MOUSE_CLICK, mousePressEvent)
    createListener(EVENT_MOUSE_RELEASE, mouseReleaseEvent)
    createListener(EVENT_LINE_ENTER, lineEnterEvent)
    initWires()
    
    camera.zoom = 1.0
    camera.zoomTrg = 1.0

    if paramCount() > 0:
      var inFile = absolutePath(paramStr(1))
      setCurrentDir(splitFile(inFile).dir)
      opened = inFile

      var input = open(inFile, fmRead)
      cards = loadCards(input.readAll(), camera, icons)
      input.close()
    
  proc Update(dt: float, delayed: bool): bool =
    if dt >= CAM_SPEED:
      camera.zoom = camera.zoomTrg
    else:
      camera.zoom += (camera.zoomTrg - camera.zoom) / CAM_SPEED * dt.float32

    for c in cards:
      c.update(dt)

    if drag:
      camera.target = dragCamStart + dragStart - mousePos

    mousePos += camera.update(size.toVector2() / unit, dt)

    cursor.update(dt)

    timer += dt

    selOffset = abs(sin(timer * 4) * unit / 8) + unit / 4
    curOffset = abs(sin(timer * 4) * unit / 8) + unit / 4
    textureOffset = camera.position * unit - size.toVector2() / 2

    selSprite = selSprite.scale(Scale8x(unit))
    curSprite = curSprite.scale(Scale8x(unit))
    resSprite = resSprite.scale(Scale8x(unit))
    boxSprite = boxSprite.scale(Scale8x(unit / 2))
    checkSprite = checkSprite.scale(Scale8x(unit / 2))

  proc Draw(ctx: var GraphicsContext) =
    ctx.setFullscreen(fullscreen)
    clearBuffer(ctx, BG_COLOR)

    for x in (camera.position.x).toGrid() - (size.x.float32 / unit / 8).int..(camera.position.x).toGrid() + (size.x.float32 / unit / 8).int + 2:
      for y in (camera.position.y).toGrid() - (size.y.float32 / unit / 8).int..(camera.position.y).toGrid() + (size.y.float32 / unit / 8).int + 2:
        gridSprite.draw(newRect(x.float32 * unit * 4, y.float32 * unit * 4, unit.float32 * 4, unit.float32 * 4), color=GRID_COLOR)

    finishDraw()

    cards.drawWires(unit)

    for c in cards:
      c.draw(unit)
    
    for c in cards:
      c.drawText(uiFont, unit)

    for c in cards:
      c.drawSel(unit, ord(curMode))
   
    if curMode == kbWire:
      finishDraw()
      cards.drawWires(unit)

    cursor.draw(unit)

  proc gameClose() =
    discard
