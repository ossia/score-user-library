/*{
  "DESCRIPTION": "Infinite Heart of Glass",
  "CREDIT": "c0d3rguy (ported from https://www.vertexshaderart.com/art/iE3Xz7bewdDm3shFC)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Abstract"
  ],
  "POINT_COUNT": 256,
  "PRIMITIVE_MODE": "LINE_STRIP",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 140,
    "ORIGINAL_DATE": {
      "$date": 1446230771097
    }
  }
}*/

void main() {

  float t = time + 5.0;

  float sndx = texture(sound, vec2(0.4, 0.4)).r;
  float sndy = texture(sound, vec2(0.2, 0.2)).r;

  float xo = vertexId / 128.0;
  float yo = vertexId / 64.0;

  vec2 xy = vec2(cos(xo * t) * 2.0 * sndx,
        sin(yo * t) * 2.0 * sndy * sndx);
  xy *= 0.8;

  gl_Position = vec4(xy, 0, 1);

  v_color = vec4(vec3(clamp(xy.y + 0.8, 0.0, 1.0),
        clamp(xy.x + 0.7, 0.0, 1.0),
        clamp(xy.y + 0.8, 0.0, 1.0)), 1.0);
}