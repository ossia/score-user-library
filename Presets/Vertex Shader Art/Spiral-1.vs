/*{
  "DESCRIPTION": "Spiral",
  "CREDIT": "richtowns (ported from https://www.vertexshaderart.com/art/A6iuFb7Tmao4i5avw)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 10000,
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
    "ORIGINAL_VIEWS": 44,
    "ORIGINAL_DATE": {
      "$date": 1496673608539
    }
  }
}*/

void main () {
  float v = vertexId;
  //float sndFactor = texture(sound, vec2(;
  float off = .1;

  float spiral = 1. - 1.7 * vertexId / (vertexCount+vertexCount);
  float scale = 1.;
  float grid = floor(vertexCount / 1000.);
  float sndFactor = texture(sound, vec2(mod(v, 20.), 0)).r;

  float x = sin(v / 100. + sndFactor) * spiral;
  float y = cos(v / 100.) * spiral;

  float ux = x * scale - off;
  float uy = y * scale - off;

  gl_Position =vec4(ux, uy, 0, 1);
  gl_PointSize = 5. ;// grid;
  //v_color = vec4(sin(spiral), sin(time/1.1), sin(time), 1);
  v_color = vec4(sin(spiral * 5. +time), 0.1, 0.5, 1);
}