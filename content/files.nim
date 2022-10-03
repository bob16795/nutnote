import nimres

const root = currentSourcePath() & "/.."

resToc(root, "content.bin",
    "8x.png",
    "32x.png",
)

static:
  echo staticExec("cp content.bin ../content.bin")