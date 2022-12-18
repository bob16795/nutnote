import hangover

const
    BG_COLOR* = newColor(46, 52, 64)
    GRID_COLOR* = newColor(67, 76, 94)
    PROG_COLOR* = newColor(161, 184, 207)
    CARD_COLOR* = newColor(129, 161, 193)
    BORDER_COLOR* = newColor(94, 129, 172)
    ICON_COLOR* = newColor(94, 129, 172)
    TEXT_COLOR* = newColor(76, 86, 106)
    ERR_COLOR* = newColor(191, 97, 106)

    CAM_SPEED* = 0.1
    CAM_DRAG_SPEED* = 3

    CUR_SPEED* = 0.05

    FONT_SIZE* = 28

template ScaleFont*(height: float32): float32 = height / FONT_SIZE / 2
