/*{
  "DESCRIPTION": "universe so big",
  "CREDIT": "richtowns (ported from https://www.vertexshaderart.com/art/e6LP3FE5P3qePgJk6)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 100000,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 49,
    "ORIGINAL_DATE": {
      "$date": 1496657415691
    }
  }
}*/

void main () {
  float v = vertexId;
  //float sndFactor = texture(sound, vec2(;
  float off = .1;
  float scale = 0.0001 * vertexCount / vertexId;
  float grid = floor(vertexCount / 1000.);

  float x = sin(v + scale + time);
  float y = cos(v + time / 1.3 );

  float ux = x * scale - off;
  float uy = y * scale - off;

  gl_Position =vec4(ux, uy, 0, 1);
  gl_PointSize = 10. * scale ;// grid;
  v_color = vec4(sin(scale), sin(vertexId), sin(time), 1);

}