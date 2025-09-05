/*{
  "DESCRIPTION": "Cold Soundwave Experiment - Just messing around with positioning and sound textures.",
  "CREDIT": "brendon (ported from https://www.vertexshaderart.com/art/NPRtMLeXooWxf64wn)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 5000,
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
    "ORIGINAL_VIEWS": 6,
    "ORIGINAL_DATE": {
      "$date": 1525449458762
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
  float point = vertexId / vertexCount;
  float cols = mod(vertexId, 100.0) * 0.01;
  float rows = floor(vertexId / 100.0) * 0.025;

  float track = texture(sound, vec2(point, pow(point, 1000.0))).r;

  float z = sin(point * point * time) * 0.5;
  float x = cols - 0.5 + z;
  float y = rows * track * point;

  gl_Position = vec4(x, y, 0.0, 1.0);
  gl_PointSize = track * pow(point, 3.0) * 50.0;
  v_color = vec4(track * y * x, x, 1.0 - y, 1.0);
}