import hangover
import json
import card
import cards/[todo, note, script, image]
import camera
import oids
import native_dialogs
import tables
import undo
import os

var opened*: string

proc saveCards*(cam: Camera, cards: seq[Card], new = false) =
  var cardData = %*[]
  var wires = %*[]
  for c in cards:
    var data = $$c
    for p in c.parents:
      wires &= %*{
          "start": $p.id,
          "end": $c.id,
        }
    cardData &= data

  var jsonData = %*{
    "wires": wires,
    "cards": cardData,
    "camera": {
      "zoom": cam.zoomTrg,
      "position": {
        "x": cam.pos.x,
        "y": cam.pos.y,
      }
    }
  }

  var outfile = opened
  if new or opened == "": 
    outfile = callDialogFileSave("Save File")
    if outfile == "": return
    opened = outfile

  var output = open(outfile, fmWrite)
  output.write(pretty(jsonData))
  output.close()

proc loadCards*(file: string, cam: var Camera, icons: Table[string, Sprite]): seq[Card] =
  var json = parseJson(file)

  for c in json["cards"]:
    let l = c["location"]
    let m = c["min"]
    case c["kind"].getStr()
    of "Card":
      result &= Card(
        icon: icons[c["kind"].getStr("Note")],
        id: parseOid(c["id"].getStr()),
        target: newRect(l["x"].getFloat(), l["y"].getFloat(), l["w"].getFloat(), l["h"].getFloat()),
        actBounds: newRect(l["x"].getFloat(), l["y"].getFloat(), l["w"].getFloat(), l["h"].getFloat()),
        text: c["text"].getStr(),
        minx: m["x"].getFloat(),
        miny: m["y"].getFloat(),
        )
    of "Todo":
      result &= TodoCard(
        icon: icons[c["kind"].getStr("Note")],
        done: c["done"].getBool(),
        id: parseOid(c["id"].getStr()),
        target: newRect(l["x"].getFloat(), l["y"].getFloat(), l["w"].getFloat(), l["h"].getFloat()),
        actBounds: newRect(l["x"].getFloat(), l["y"].getFloat(), l["w"].getFloat(), l["h"].getFloat()),
        text: c["text"].getStr(),
        minx: m["x"].getFloat(),
        miny: m["y"].getFloat(),
        )
    of "Note":
      result &= NoteCard(
        icon: icons[c["kind"].getStr("Note")],
        id: parseOid(c["id"].getStr()),
        target: newRect(l["x"].getFloat(), l["y"].getFloat(), l["w"].getFloat(), l["h"].getFloat()),
        actBounds: newRect(l["x"].getFloat(), l["y"].getFloat(), l["w"].getFloat(), l["h"].getFloat()),
        text: c["text"].getStr(),
        minx: m["x"].getFloat(),
        miny: m["y"].getFloat(),
        )
    of "Script":
      result &= newScriptCard(
        newRect(l["x"].getFloat(), l["y"].getFloat(), l["w"].getFloat(), l["h"].getFloat()),
        c["file"].getStr(),
        newPoint(m["x"].getFloat().int,
                 m["y"].getFloat().int),
        icons[c["kind"].getStr("Note")],
        parseOid(c["id"].getStr()),
        )
    of "Image":
      result &= newImageCard(
        newRect(l["x"].getFloat(), l["y"].getFloat(), l["w"].getFloat(), l["h"].getFloat()),
        c["file"].getStr(),
        newPoint(m["x"].getFloat().int,
                 m["y"].getFloat().int),
        icons[c["kind"].getStr("Note")],
        parseOid(c["id"].getStr()),
        )
    else:
      discard
  
  for w in json["wires"]:
    block wire:
      for c1 in result:
        if $c1.id == w["start"].getStr():
          for c2 in result:
            if $c2.id == w["end"].getStr():
              c2.parents &= c1
              break wire
  if "camera" in json:
    cam.pos.x = json["camera"]["position"]["x"].getFloat(0)
    cam.pos.y = json["camera"]["position"]["y"].getFloat(0)
    cam.target.x = json["camera"]["position"]["x"].getFloat(0)
    cam.target.y = json["camera"]["position"]["y"].getFloat(0)
    cam.zoom = json["camera"]["zoom"].getFloat(1)
    cam.zoomTrg = json["camera"]["zoom"].getFloat(1)

  hist.actions = @[]
  hist.actionIdx = 0
        

proc openFile*(cam: var Camera, cards: var seq[Card], icons: Table[string, Sprite]) =
  var infile = callDialogFileOpen("Select File")
  if infile == "": return
  setCurrentDir(splitFile(infile).dir)
  opened = infile
  
  var input = open(infile, fmRead)
  cards = loadCards(input.readAll(), cam, icons)
  input.close()
