/*{
  "DESCRIPTION": "Bezier Curves",
  "CREDIT": "przemyslawzaworski (ported from https://www.vertexshaderart.com/art/J4JLEuTrJFshLPKeg)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 65536,
  "PRIMITIVE_MODE": "LINES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    1,
    1,
    1,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 227,
    "ORIGINAL_LIKES": 1,
    "ORIGINAL_DATE": {
      "$date": 1639261039069
    }
  }
}*/

// https://en.wikipedia.org/wiki/B%C3%A9zier_curve
vec2 BezierCurve (vec2 a, vec2 b, vec2 c, vec2 d, float t)
{
 float x = a.x * (1.0 - t) * (1.0 - t) * (1.0 - t) + 3.0 * b.x * t * (1.0 - t) * (1.0 - t) + 3.0 * c.x * t * t * (1.0 - t) + d.x * t * t * t;
 float y = a.y * (1.0 - t) * (1.0 - t) * (1.0 - t) + 3.0 * b.y * t * (1.0 - t) * (1.0 - t) + 3.0 * c.y * t * t * (1.0 - t) + d.y * t * t * t;
 return vec2 (x, y);
}

// https://www.shadertoy.com/view/4djSRW
// Returns value in range -1..1
vec4 Hash (float p)
{
 vec4 p4 = fract(vec4(p) * vec4(.1031, .1030, .0973, .1099));
 p4 += dot(p4, p4.wzxy + 33.33);
 return fract((p4.xxyz + p4.yzzw) * p4.zywx) * 2.0 - 1.0;
}

// https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/mod.xhtml
float Mod (float x, float y)
{
 return x - y * floor(x / y);
}

void main()
{
 float strand = 64.0; // amount of vertices per strand
 float instance = floor(vertexId / strand); // instance ID
 float id = Mod(vertexId, strand); // vertex ID
 float t = max((id + Mod(id, 2.0) - 1.0), 0.0) / (strand - 1.0); // interpolator
 vec4 n = Hash(instance); // noise
 vec2 coords = BezierCurve(vec2(n.x + sin(time), n.y - cos(time)), n.xy, n.zw, vec2(-sin(time), cos(time)), t);
 gl_Position = vec4(coords, 0, 1);
 v_color = vec4(n.xyz, 1);
}