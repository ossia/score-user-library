/*{
  "DESCRIPTION": "sine",
  "CREDIT": "foxhunt (ported from https://www.vertexshaderart.com/art/3K4d92nvq5JFcZa8K)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 262,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0.20784313725490197,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 1,
    "ORIGINAL_DATE": {
      "$date": 1570109787427
    }
  }
}*/

#define PI 3.1415926535897932384626433832795

float oscillate(float i, float mi, float ma) {
  float r = ma - mi;
  float o = mi + abs(mod(i + r, r * 2.) - r);
  return o;
}

void main() {

  float x = mod(time * .4 + (vertexId / vertexCount * 2. - 1.), 2.) - 1.;

  float y = sin(x * PI * 10.) * oscillate(time * .02, -.2, .2);

  gl_Position = vec4(x, y, 0, 1);

  gl_PointSize = 3.;

  v_color = vec4(1, 0, 0, 1);
}