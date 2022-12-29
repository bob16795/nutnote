import hangover
import nimscripter
import strutils
import sets
import os
import parseutils
import sugar
from tables import `[]=`, `[]`, toTable, Table, contains

type
  kbMode* = object
    name*: string
    wiresAbove*: bool
    editing*: bool
    colors*: Table[string, Color]
  kbActionKind* = enum
    kakNull
    kakMove
    kakSelect
    kakFile
    kakDelete
    kakClear
    kakCall
    kakHist
    kakMode
    kakText
    kakFullscreen
    kakToggle
    kakClipboard
    kakMenu
  kbAction* = ref object
    case kind*: kbActionKind
    of kakCall:
      callProc*: proc()
    of kakMove:
      moveDir*: Point
    of kakSelect:
      selAll*: bool
    of kakFile:
      fileOpen*: bool
    of kakHist:
      histUndo*: bool
    of kakMode:
      mode*: int
    of kakText:
      text*: string
    of kakClipboard:
      cbCopy*: bool
    else: discard
  kbMods* = object
    alt*: bool
    shift*: bool
    ctrl*: bool
  kbBind* = object
    mode*: int
    mods*: kbMods
    key*: Key
    action*: kbAction

const 
  DEFAULT_SETTINGS = [
    ("position", "false"),
    ("status", "true"),
    ("status_height", "60"),
    ("status_padding", "10"),
  ].toTable()


template newBind(nmode: int, keybind: Key, a, s, c: bool, act: kbAction): untyped =
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
  
var
  binds*: seq[kbBind]
  modes*: Table[int, kbMode]
  actions*: Table[string, proc()]

proc getAction*(text: string): kbAction =
  var args = text.split(" ")
  case args[0]:
  of "del":
    result = kbAction(kind: kakDelete)
  of "text":
    result = kbAction(kind: kakText, text: args[1])
  of "open":
    result = kbAction(kind: kakFile, fileOpen: true)
  of "save":
    result = kbAction(kind: kakFile, fileOpen: false)
  of "move":
    result = kbAction(kind: kakMove, moveDir: newPoint(parseInt(args[1]), parseInt(args[2])))
  of "mode":
    result = kbAction(kind: kakMode, mode: parseInt(args[1]))
  of "menu":
    result = kbAction(kind: kakMenu)
  of "sel":
    case args[1]:
    of "all":
      result = kbAction(kind: kakSelect, selAll: true)
    of "none":
      result = kbAction(kind: kakSelect, selAll: false)
    else:
      result = kbAction(kind: kakNull)
  of "clear":
    result = kbAction(kind: kakClear)
  of "undo":
    result = kbAction(kind: kakHist, histUndo: true)
  of "redo":
    result = kbAction(kind: kakHist, histUndo: false)
  of "toggle":
    result = kbAction(kind: kakToggle)
  else:
    result = kbAction(kind: kakNull)
    if args[0] in actions:
      result = kbAction(kind: kakCall, callProc: actions[args[0]])

var scripts*: seq[Option[Interpreter]]
var runActionThing*: proc(action: kbAction)
var settings*: Table[string, string] = DEFAULT_SETTINGS

proc getSettingBool*(name: string): bool =
  return not (settings[name] == "")

proc getSettingInt*(name: string): int =
  result = parseInt(settings[name])

proc getColor*(m: kbMode, name: string): Color =
  if name in m.colors:
    return m.colors[name]
  else:
    return m.colors["default"]

proc sourceFile*(file: string) =
  var index = len(scripts)

  capture index:
    proc initMode(id: int, name: string) =
      modes[id] = kbMode(name: name)
      modes[id].colors["default"] = newColor(255, 255, 255)

    proc nameMode(id: int, name: string) =
      modes[id].name = name
      
    proc flagMode(id: int, key: string, value: bool) =
      case key:
      of "edit":
        modes[id].editing = value
      of "wires":
        modes[id].wiresAbove = value

    proc bindMode(modeId: int, key: string, action: string) =
      var keyName = key.split("-")[^1]
      var keyMods: set[char]
      if "-" in key:
        for e in key.split("-")[0..^2]:
          keyMods = keyMods + {e[0]}

      var keycode: Key
      if keyName.len() == 1:
        keycode = cast[Key](cast[int](keyName[0]) - cast[int]('A') + cast[int](keyA))
      else:
        case keyName:
        of "Del":
          keycode = keyDelete
        of "Esc":
          keycode = keyEscape
        of "Spc":
          keycode = keySpace
        of ":":
          keycode = keySemicolon
      binds &= newBind(modeId, keycode, 'A' in keyMods, 'S' in keyMods, 'C' in keyMods, getAction(action))

    proc hiMode(mode: int, name: string, r, g, b: int) =
      modes[mode].colors[name] = newColor(r.uint8, g.uint8, b.uint8)

    proc runAct(action: string) =
      runActionThing(getAction(action))

    proc regAct(action: string, act: string) =
      actions[action] = proc () = scripts[^1].get().invokeDynamic(act)

    proc setb(setting: string, value: bool) =
      if value:
        settings[setting] = "true"
      else:
        settings[setting] = ""

    proc seti(setting: string, value: int) =
      settings[setting] = $value

    proc sets(setting: string, value: string) =
      settings[setting] = value

    proc log(data: string) =
      LOG_INFO "nutnote->cfg", data

    exportTo(myImpl,
      initMode,
      nameMode,
      flagMode,
      bindMode,
      hiMode,
      runAct,
      regAct,
      setb,
      seti,
      sets,
      log,
      )
    const scriptProcs = implNimScriptModule(myImpl)

    scripts &= loadScript(NimScriptPath(file), scriptProcs, stdPath = getAppDir() / "stdlib")
