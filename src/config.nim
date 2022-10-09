import hangover

type
  kbMode* = enum
    kbNormal
    kbEdit
    kbWire
  kbActionKind* = enum
    kakMove
    kakSelect
    kakFile
    kakDelete
    kakHist
    kakMode
    kakEdit
    kakFullscreen
    kakToggle
  kbAction* = object
    case kind*: kbActionKind
    of kakMove:
      moveDir*: Point
    of kakSelect:
      selAll*: bool
    of kakFile:
      fileOpen*: bool
    of kakHist:
      histUndo*: bool
    of kakMode:
      mode*: kbMode
    of kakEdit:
      editClear*: bool
    else: discard
  kbMods* = object
    alt*: bool
    shift*: bool
    ctrl*: bool
  kbBind* = object
    mode*: kbMode
    mods*: kbMods
    key*: Key
    action*: kbAction

template newBind(nmode: kbMode, keybind: Key, a, s, c: bool, act: kbAction): untyped =
  kbBind(
    mode: nmode,
    mods: kbMods(
      alt: a,
      shift: s,
      ctrl: c
    ),
    key: keybind,
    action: act,
  )

const
  defaultBinds*: seq[kbBind] = @[
    newBind(kbNormal, keyW, false, false, false, kbAction(kind: kakMove, moveDir: newPoint(0, -4))),
    newBind(kbNormal, keyA, false, false, false, kbAction(kind: kakMove, moveDir: newPoint(-4, 0))),
    newBind(kbNormal, keyS, false, false, false, kbAction(kind: kakMove, moveDir: newPoint(0, 4))),
    newBind(kbNormal, keyD, false, false, false, kbAction(kind: kakMove, moveDir: newPoint(4, 0))),
    newBind(kbNormal, keyA, false, false, true, kbAction(kind: kakSelect, selAll: true)),
    newBind(kbNormal, keyA, false, true, true, kbAction(kind: kakSelect, selAll: false)),
    newBind(kbNormal, keyO, false, false, true, kbAction(kind: kakFile, fileOpen: true)),
    newBind(kbNormal, keyDelete, false, false, false, kbAction(kind: kakDelete)),
    newBind(kbNormal, keyZ, false, false, true, kbAction(kind: kakHist, histUndo: true)),
    newBind(kbNormal, keyZ, false, true, true, kbAction(kind: kakHist, histUndo: false)),
    newBind(kbNormal, keyY, false, false, true, kbAction(kind: kakHist, histUndo: false)),
    newBind(kbNormal, keyV, false, false, false, kbAction(kind: kakMode, mode: kbWire)),
    newBind(kbNormal, keyE, false, false, false, kbAction(kind: kakEdit, editClear: false)),
    newBind(kbNormal, keyF11, false, false, false, kbAction(kind: kakFullscreen)),
    newBind(kbNormal, keyR, false, false, false, kbAction(kind: kakEdit, editClear: true)),
    newBind(kbNormal, keySpace, false, false, false, kbAction(kind: kakToggle)),
    
    newBind(kbEdit, keyEscape, false, false, false, kbAction(kind: kakMode, mode: kbNormal)),

    newBind(kbWire, keyEscape, false, false, false, kbAction(kind: kakMode, mode: kbNormal)),
  ]
