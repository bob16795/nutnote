import hangover

const
    ICON_COLOR* = newColor(94, 129, 172)

    CAM_SPEED* = 0.1
    CAM_DRAG_SPEED* = 3

    CUR_SPEED* = 0.05

    FONT_SIZE* = 28

template ScaleFont*(height: float32): float32 = height / FONT_SIZE / 2
