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

bindMode 0, "E", "mode 2"
bindMode 0, "R", "edit"
bindMode 0, "V", "mode 1"
bindMode 0, "C-A", "sel all"
bindMode 0, "C-S-A", "sel none"
bindMode 0, "C-O", "open"
bindMode 0, "C-S", "save"
bindMode 0, "Del", "del"
bindMode 0, "Spc", "toggle"

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

# Edit mode

initMode 2, "Edit"
flagMode 2, "wires", false
flagMode 2, "edit", true

bindMode 2, "C-R", "clear"
bindMode 2, "Esc", "mode 0"

# color stuff

hiMode 0, 200, 200, 200
hiMode 1, 180, 142, 173
hiMode 2, 235, 203, 139