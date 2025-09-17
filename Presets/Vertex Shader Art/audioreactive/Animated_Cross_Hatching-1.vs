/*{
  "DESCRIPTION": "Animated Cross Hatching - First vertex shader",
  "CREDIT": "brendon (ported from https://www.vertexshaderart.com/art/SJ68p365upswGjcG9)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 20000,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0.27450980392156865,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 11,
    "ORIGINAL_LIKES": 1,
    "ORIGINAL_DATE": {
      "$date": 1523273314937
    }
  }
}*/

void main() {
  float n = vertexId / vertexCount;
  vec4 snd = texture(sound, vec2(0.0, 0.0));
  float angle = n * 6.28;
  float dx = cos(angle);
  float dy = sin(angle * (time / 100.0));

  gl_Position = vec4(dx, dy, 0.0, 1);
  gl_PointSize = pow(snd.a, 2.0) * 5.0;
  v_color = vec4(snd.a, snd.b, cos(time), 1.0);
}