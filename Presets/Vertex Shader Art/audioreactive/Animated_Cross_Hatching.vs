/*{
  "DESCRIPTION": "Animated Cross Hatching - First vertex shader",
  "CREDIT": "brendon (ported from https://www.vertexshaderart.com/art/4vag7ndH4zPYNfMML)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 1000,
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
    "ORIGINAL_VIEWS": 4,
    "ORIGINAL_DATE": {
      "$date": 1523299826567
    }
  }
}*/


void main() {
  float n = vertexId / vertexCount;
  vec4 snd = texture(sound, vec2(0.0, 0.0));
  float angle = n * 6.28;

  float avx = 0.5;
  float axy = 0.5;

  float dx = cos(angle * time * avx) * vertexId / 1000.0;
  float dy = sin(angle * time * axy) * vertexId / 1000.0;

  gl_Position = vec4(dx, dy, 0.0, 1);
  gl_PointSize = vertexId / 50.0;
  v_color = vec4(snd.a * snd.b, snd.b * snd.b, n, 1.0);
}