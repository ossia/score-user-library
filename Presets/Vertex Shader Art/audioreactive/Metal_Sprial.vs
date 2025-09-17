/*{
  "DESCRIPTION": "Metal Sprial",
  "CREDIT": "brendon (ported from https://www.vertexshaderart.com/art/KeyjGeoFSgZNieLtF)",
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
  "INPUTS": [ { "LABEL": "Mouse", "NAME": "mouse", "TYPE": "point2D", "DEFAULT": [0.0, 0.0], "MIN": [0.0, 0.0], "MAX": [1.0, 1.0] }, { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 4,
    "ORIGINAL_DATE": {
      "$date": 1523303236602
    }
  }
}*/


void main() {
  float n = vertexId / vertexCount;
  vec4 snd = texture(sound, vec2(0.0, 0.0));
  float angle = n * 6.28;

  float avx = 0.5;
  float axy = 0.2;

  float dx = cos(angle * time * avx) * n; // + mouse.x;
  float dy = sin(angle * time * axy) * n; // + mouse.y;

  gl_Position = vec4(dx, dy, 0.0, abs(cos(snd.a)));
  gl_PointSize = dy / resolution.y * n * 10.0;
  v_color = vec4(abs(dy / dx), abs(dx / dy), dy / dx, 1.0);
}