import hangover
import card
import data

type
  tempVert = object
    x1, y1, z1, w1: float32
    r1, g1, b1, a1: float32

var
  LineBufferObject: GLuint
  LineVAO: GLuint
  wireProg: Shader

const
  wireFrag = """
in vec2 texCoords;
in vec4 tintColor;

out vec4 color;

uniform sampler2D text;

void main() {
  color = tintColor;
}
"""

proc initWires*() =
  glGenBuffers(1, addr LineBufferObject)
  glGenVertexArrays(1, addr LineVAO)
  wireProg = newShader(textureVertexCode, wireFrag)
  wireProg.registerParam("projection", SPKProj4)
  regShader(wireProg)

proc drawWires*(c: Card, unit: float32) =
  glDisable(GL_BLEND)
  glEnable(GL_LINE_SMOOTH)
  var verts: seq[tempVert]
  for parent in c.parents:
    var
      pb = parent.actBounds.scale(unit).center() - textureOffset
      cb = c.actBounds.scale(unit).center() - textureOffset
      temp = tempVert()
      color = mix(PROG_COLOR, CARD_COLOR, parent.progress)
    if parent.progress > 1.0 or parent.progress < 0.0:
      color = ERR_COLOR

    var d = normal(pb - cb) * unit / 8
    var d_left = newVector2(-d.y, d.x)
    var d_right = newVector2(d.y, -d.x)

    temp.w1 = 1.0
    temp.a1 = 1.0
    temp.r1 = BORDER_COLOR.rf
    temp.g1 = BORDER_COLOR.gf
    temp.b1 = BORDER_COLOR.bf
    temp.x1 = pb.x + d_left.x
    temp.y1 = pb.y + d_left.y
    verts &= temp
    temp.x1 = cb.x + d_right.x
    temp.y1 = cb.y + d_right.y
    verts &= temp
    temp.x1 = cb.x + d_left.x
    temp.y1 = cb.y + d_left.y
    verts &= temp
    temp.x1 = pb.x + d_left.x
    temp.y1 = pb.y + d_left.y
    verts &= temp
    temp.x1 = cb.x + d_right.x
    temp.y1 = cb.y + d_right.y
    verts &= temp
    temp.x1 = pb.x + d_right.x
    temp.y1 = pb.y + d_right.y
    verts &= temp

    d_right /= 2
    d_left /= 2
    temp.r1 = color.rf
    temp.g1 = color.gf
    temp.b1 = color.bf
    temp.x1 = pb.x + d_left.x
    temp.y1 = pb.y + d_left.y
    verts &= temp
    temp.x1 = cb.x + d_right.x
    temp.y1 = cb.y + d_right.y
    verts &= temp
    temp.x1 = cb.x + d_left.x
    temp.y1 = cb.y + d_left.y
    verts &= temp
    temp.x1 = pb.x + d_left.x
    temp.y1 = pb.y + d_left.y
    verts &= temp
    temp.x1 = cb.x + d_right.x
    temp.y1 = cb.y + d_right.y
    verts &= temp
    temp.x1 = pb.x + d_right.x
    temp.y1 = pb.y + d_right.y
    verts &= temp

  if verts == @[]:
    return

  glBindVertexArray(LineVAO)
  glBindBuffer(GL_ARRAY_BUFFER, LineBufferObject);
  glBufferData(GL_ARRAY_BUFFER, (sizeof(tempVert)).int * len(verts), addr verts[0], GL_DYNAMIC_DRAW);

  glVertexAttribPointer(0, 4, cGL_FLOAT, false, 8 * sizeof(GLFloat), cast[pointer](0))
  glEnableVertexAttribArray(0)
  glVertexAttribPointer(1, 4, cGL_FLOAT, false, 8 * sizeof(GLFloat), cast[pointer](4 * sizeof(GLFloat)))
  glEnableVertexAttribArray(1)

  glUseProgram(wireProg.id)

  glLineWidth(unit / 2)
  glDrawArrays(GL_TRIANGLES, 0, len(verts).Glint)
