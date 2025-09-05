/*{
  "DESCRIPTION": "Motion Variation",
  "CREDIT": "daehyeon.kim (ported from https://www.vertexshaderart.com/art/ePt2CZtNzQzvEYWAy)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 2262,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.06274509803921569,
    0.13333333333333333,
    0.27450980392156865,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 3,
    "ORIGINAL_DATE": {
      "$date": 1652887531413
    }
  }
}*/

//Daehyeon Kim
//Motion
//CS250
//Spring, 2022
void main() {
  float down = sqrt(vertexCount);
  float across = floor(vertexCount / down);
  float x = mod(vertexId, across);
  float y = floor(vertexId / across);

  float u = x / (across - 1.);
  float v = y / (across - 1.);

  float xoff = sin(time + y * 0.2) * 0.1;
  float yoff = sin(time + x * 0.3) * 0.2;

  float ux = u * 2. - 1. + xoff;
  float vy = v * 2. - 1. + yoff;

  vec2 xy = vec2(ux, vy) * 1.3;
  float snd = texture(sound, vec2(sin(time) - 1. , cos(time) - 1.)).b;

  gl_Position = vec4(xy.x,xy.y , 0, 1);

  float soff = sin(time + x * y * .02) * 5.;
  gl_PointSize = 15.0 + soff + (snd * 200.) / 20.;
  gl_PointSize *= 20.0 / across;
  gl_PointSize *= resolution.x / 600.0;
  v_color = vec4(1, snd, 0, 1);
}