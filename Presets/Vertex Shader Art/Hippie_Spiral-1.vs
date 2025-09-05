/*{
  "DESCRIPTION": "Hippie Spiral",
  "CREDIT": "brendon (ported from https://www.vertexshaderart.com/art/sph6PXJZqMbGaLSkY)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 2000,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 7,
    "ORIGINAL_DATE": {
      "$date": 1523300354053
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
  gl_PointSize = vertexId / 0.0;
  v_color = vec4(snd.a, n, cos(time * n), 1.0);
}