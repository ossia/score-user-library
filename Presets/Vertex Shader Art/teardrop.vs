/*{
  "DESCRIPTION": "teardrop",
  "CREDIT": "orange4glace (ported from https://www.vertexshaderart.com/art/XBmtPpZobE3xxRQ9e)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 16384,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 3,
    "ORIGINAL_DATE": {
      "$date": 1644671059304
    }
  }
}*/

#define PI radians(180.)

void main() {
  float t = vertexId / vertexCount * PI * 2.;
  float t2 = vertexId / vertexCount * PI * 4.;
  float m = mod(time, 4.) / 2.;
  float y = cos(t);
  float x= sin(t) * pow(sin(0.5 * t), m);

  gl_Position = vec4(x / resolution.x * 800., y / resolution.y * 800., 0, 1.0);
  v_color = vec4(1, 1, 1, 1);
}