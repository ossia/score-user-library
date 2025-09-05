/*{
  "DESCRIPTION": "study",
  "CREDIT": "shinyisshiny (ported from https://www.vertexshaderart.com/art/DpHdSTbEXuhA4ZhTJ)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 2766,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.03137254901960784,
    0.050980392156862744,
    0.32941176470588235,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 1,
    "ORIGINAL_DATE": {
      "$date": 1588529037574
    }
  }
}*/

#define positionX 3.//KParameter 0.>>10.
#define positionY 1.//KParameter 0.>>1.
#define colorR 1.//KParameter 0.>>1.
#define colorG 1.//KParameter 0.>>1.
#define colorB 1.//KParameter 0.>>1.
#define rotationFactorX 1.//KParameter 0.>>8.
#define rotationFactorY 1.//KParameter 0.>>8.
#define rotationFactorZ 1.//KParameter 0.>>8.

void main() {
  float down = floor(sqrt(vertexCount));
  float across = floor(vertexCount / down);

  float x = mod(vertexId, across);
  float y = floor(vertexId / across);

  float u = x / (across - 1.);
  float v = y / (across - 1.);

  float xoff = sin(time + y * 0.2) * 0.9;
  float yoff = sin(time + x * 0.3) * 0.2;

  float ux = u * 2. - 1. + xoff;
  float vy = v * 2. - 1. + yoff;

  vec2 xy = vec2(ux, vy) * 1.3;

  float snd = texture(sound, vec2(u, v * 0.)).r;

  gl_Position = vec4(ux, vy, 0, 1);

  float soff = sin(time + x * y * 0.6) * 15.;

  gl_PointSize = snd * 100.0 + soff;
  gl_PointSize *= 20. / across;
  gl_PointSize *= resolution.x / 600.;

  v_color = vec4(1, v, 1, 1);

}

