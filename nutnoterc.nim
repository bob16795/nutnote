# this is the default rc for nutnote

proc clearEdit*() =
  runAct "mode 2"
  runAct "clear"

regAct "edit", "clearEdit"

# Normal mode

initMode 0, "Normal"
flagMode 0, "wires", false
flagMode 0, "edit", false

bindMode 0, "W", "move 0 -4"
bindMode 0, "A", "move -4 0"
bindMode 0, "S", "move 0 4"
bindMode 0, "D", "move 4 0"
bindMode 0, "C-Z", "undo"
bindMode 0, "C-S-Z", "redo"
bindMode 0, "C-Y", "redo"
bindMode 0, "C-S-P", "menu"

bindMode 0, "E", "mode 2"
bindMode 0, "R", "edit"
bindMode 0, "V", "mode 1"
bindMode 0, "C-A", "sel all"
bindMode 0, "C-S-A", "sel none"
bindMode 0, "C-O", "open"
bindMode 0, "C-S", "save"
bindMode 0, "Del", "del"
bindMode 0, "Spc", "toggle"

log "Normal Init"

# Wire mode

initMode 1, "Wire"
flagMode 1, "wires", true
flagMode 1, "edit", false

bindMode 1, "W", "move 0 -4"
bindMode 1, "A", "move -4 0"
bindMode 1, "S", "move 0 4"
bindMode 1, "D", "move 4 0"
bindMode 1, "C-S-Z", "redo"
bindMode 1, "C-Z", "undo"
bindMode 1, "C-Y", "redo"

bindMode 1, "Esc", "mode 0"

log "Wire Init"

# Edit mode

initMode 2, "Edit"
flagMode 2, "wires", false
flagMode 2, "edit", true

bindMode 2, "C-R", "clear"
bindMode 2, "Esc", "mode 0"

log "Edit Init"

# color stuff

#         name       , r  , g  , b
hiMode 0, "selection", 200, 200, 200
hiMode 0, "bg"       , 46 , 52 , 64
hiMode 0, "grid"     , 67 , 76 , 94
hiMode 0, "card"     , 129, 161, 193
hiMode 0, "border"   , 94 , 129, 172
hiMode 0, "progress" , 161, 184, 207
hiMode 0, "err"      , 191, 97 , 106
hiMode 0, "text"     , 76 , 86 , 106
hiMode 0, "status"   , 76 , 86 , 106

hiMode 1, "selection", 180, 142, 173
hiMode 1, "bg"       , 46 , 52 , 64
hiMode 1, "grid"     , 67 , 76 , 94
hiMode 1, "card"     , 129, 161, 193
hiMode 1, "border"   , 94 , 129, 172
hiMode 1, "progress" , 161, 184, 207
hiMode 1, "err"      , 191, 97 , 106
hiMode 1, "text"     , 76 , 86 , 106
hiMode 1, "status"   , 76 , 86 , 106

hiMode 2, "selection", 235, 203, 139
hiMode 2, "bg"       , 46 , 52 , 64
hiMode 2, "grid"     , 67 , 76 , 94
hiMode 2, "card"     , 129, 161, 193
hiMode 2, "border"   , 94 , 129, 172
hiMode 2, "progress" , 161, 184, 207
hiMode 2, "err"      , 191, 97 , 106
hiMode 2, "text"     , 76 , 86 , 106
hiMode 2, "status"   , 76 , 86 , 106

setb "position", false
setb "status", true
seti "status_height", 40
seti "status_padding", 10