/*{
  "DESCRIPTION": "music",
  "CREDIT": "feathj (ported from https://www.vertexshaderart.com/art/6nPKwArJkv4Rbz6LX)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Particles"
  ],
  "POINT_COUNT": 920,
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
      "$date": 1632427305963
    }
  }
}*/


vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {
  float down = floor(sqrt(vertexCount));
  float across = floor(vertexCount / down);
  float x = mod(vertexId, across);
  float y = floor(vertexId / across);
  float u = x / (across - 1.0);
  float v = y / (across - 1.0);

  float snd = texture(sound, vec2(u, v)).r;

  gl_Position = vec4(0.0, 0.1 * snd, 0.0, 1.0);
  gl_PointSize = 50.0;

  v_color = vec4(hsv2rgb(vec3(1.0, 1.0, snd)), 1.0);
}
