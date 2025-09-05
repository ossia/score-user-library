/*{
  "DESCRIPTION": "circle jerk",
  "CREDIT": "richtowns (ported from https://www.vertexshaderart.com/art/L89txYMotSKb9FLad)",
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
    "ORIGINAL_VIEWS": 2,
    "ORIGINAL_DATE": {
      "$date": 1496679037909
    }
  }
}*/

void main () {
  float v = vertexId;
  //float sndFactor = texture(sound, vec2(;
  float off = .1;
  float scale = 5.; //0.001 * vertexCount / vertexId;
  float grid = floor(vertexCount / 1000.);
  float sndF = texture(sound, vec2(mod(v, 1.), 0)).r;

  float y = sin(v + time / (sndF * 20000.)) * (1. - sndF * 5.);
  float x = cos(v + time / (sndF * 18000.) ) * (1. - sndF * 7.);

  float ux = x / scale - off;
  float uy = y / scale - off;

  gl_Position =vec4(ux, uy, 0, 1);
  gl_PointSize = 1. + sndF * 10. ;// grid;
  v_color = vec4(sin(sndF), sin(v), sin(time), 1);

}