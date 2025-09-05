/*{
  "DESCRIPTION": "Loopy - My first ever vertex shader :D",
  "CREDIT": "aaron1924 (ported from https://www.vertexshaderart.com/art/6zJfYSooxERRtZtbe)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 1024,
  "PRIMITIVE_MODE": "LINES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 360,
    "ORIGINAL_LIKES": 3,
    "ORIGINAL_DATE": {
      "$date": 1535281188852
    }
  }
}*/

#define TAU 6.28318530718

mat2 rot(float a)
{
  float s=sin(a), c=cos(a);
  return mat2(c,s,-s,c);
}

void main() {
  float a = 4. * TAU * vertexId / vertexCount;

  float r = 3.25;
  vec2 off = vec2(0.5 * sin(r*a) + 1., cos(r*a));
  vec3 p = vec3(sin(a), 1, cos(a)) * off.xyx;

  p.xz *= rot(time);
  p.yz *= rot(0.8);

  gl_Position = vec4(p/(p.z+3.), 1);
  v_color = vec4(1./(p.z+2.));
}