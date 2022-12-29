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

proc drawWires*(cards: seq[Card], unit: float32, errColor, progColor, cardColor, borderColor: Color) =
  glDisable(GL_BLEND)
  var verts: seq[tempVert]
  for c in cards:
    for parent in c.parents:
      var
        pb = parent.actBounds.scale(unit).center() - textureOffset
        cb = c.actBounds.scale(unit).center() - textureOffset
        temp = tempVert()
        color = mix(progColor, cardColor, parent.progress)
        center = (pb + cb) / 2
      if parent.progress > 1.0 or parent.progress < 0.0:
        color = errColor

      var d = normal(pb - cb) * unit / 8
      var d_left = newVector2(-d.y, d.x)
      var d_right = newVector2(d.y, -d.x)
      center += d * 2

      temp.w1 = 1.0
      temp.a1 = 1.0
      temp.r1 = borderColor.rf
      temp.g1 = borderColor.gf
      temp.b1 = borderColor.bf
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

      temp.x1 = center.x + d_left.x * 4
      temp.y1 = center.y + d_left.y * 4
      verts &= temp
      temp.x1 = center.x + d_right.x * 4
      temp.y1 = center.y + d_right.y * 4
      verts &= temp
      temp.x1 = center.x - d.x * 4
      temp.y1 = center.y - d.y * 4
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
    
      temp.x1 = center.x + d_left.x * 6 
      temp.y1 = center.y + d_left.y * 6
      verts &= temp
      temp.x1 = center.x + d_right.x * 6
      temp.y1 = center.y + d_right.y * 6
      verts &= temp
      temp.x1 = center.x - d.x * 3
      temp.y1 = center.y - d.y * 3
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
