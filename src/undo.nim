import hangover
import card
import sequtils

type
  ActionKind* = enum
    akAdd,
    akDelete,
    akChange,
    akResize,
    akWire,
    akUnwire,

  Action* = ref object
    case kind*: ActionKind
    of akAdd:
      addCard*: Card
    of akChange:
      changeBefore*: string
      changeAfter*: string
      changeCard*: Card
    of akDelete:
      delCards*: seq[Card]
    of akResize:
      startSize*: Rect
      endSize*: Rect
      resCard*: Card
    of akWire, akUnwire:
      wireStart*: Card
      wireEnd*: Card

  History* = object
    actions*: seq[Action]
    actionIdx*: uint

var
  hist*: History

proc addAction*(hist: var History, act: Action) =
  if hist.actionIdx == len(hist.actions).uint:
    hist.actions &= act
  else:
    hist.actions[hist.actionIdx..^1] = [act]
  hist.actionIdx += 1

proc redo*(act: Action, cards: var seq[Card]) =
  case act.kind
  of akAdd:
    cards &= act.addCard
  of akDelete:
    for delCard in act.delCards:
      block del:
        for cardi in 0..<len cards:
          template card: untyped = cards[cardi]
          if card == delCard:
            cards.del(cardi)
            break del
  of akResize:
    for c in cards:
      if act.resCard == c:
        c.bounds = act.endSize
        return
  of akChange:
    for c in cards:
      if act.changeCard == c:
        c.text = act.changeAfter
        return
  of akWire:
    act.wireEnd.parents &= act.wireStart
  of akUnwire:
    act.wireEnd.parents.keepItIf(it != act.wireStart)
  else:
    assert(false, "Redo not implemented")

proc undo*(act: Action, cards: var seq[Card]) =
  case act.kind
  of akAdd:
    for cardi in 0..<len cards:
      template card: untyped = cards[cardi]
      if card == act.addCard:
        cards.del(cardi)
        return
  of akDelete:
    cards &= act.delCards
  of akResize:
    for c in cards:
      if act.resCard == c:
        c.bounds = act.startSize
        return
  of akChange:
    for c in cards:
      if act.changeCard == c:
        c.text = act.changeBefore
        return
  of akWire:
    act.wireEnd.parents.keepItIf(it != act.wireStart)
  of akUnwire:
    act.wireEnd.parents &= act.wireStart
  else:
    assert(false, "Undo not implemented")

proc undo*(hist: var History, cards: var seq[Card]) =
  if hist.actionIdx < 1:
    return
  hist.actionIdx -= 1
  hist.actions[hist.actionIdx].undo(cards)

proc redo*(hist: var History, cards: var seq[Card]) =
  if hist.actionIdx >= len(hist.actions).uint:
    return
  hist.actions[hist.actionIdx].redo(cards)
  hist.actionIdx += 1
