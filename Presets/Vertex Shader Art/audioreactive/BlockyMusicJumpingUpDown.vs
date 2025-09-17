/*{
  "DESCRIPTION": "BlockyMusicJumpingUpDown",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/wJR8MkZGLQe3TZGZD)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 6255,
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
    "ORIGINAL_VIEWS": 10,
    "ORIGINAL_DATE": {
      "$date": 1541248651140
    }
  }
}*/

#define PI radians(180.)
#define NUM_SEGMENTS 4.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)
#define STEP 5.0

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {
  float point = mod(floor(vertexId / 2.0) + mod(vertexId, 2.0) * STEP, NUM_SEGMENTS);
  float count = floor(vertexId / NUM_POINTS);
  vec4 soundPoint = texture(sound, vec2(fract(count / 128.0), fract(count / 20000.0)));
  float snd = soundPoint.r;

  float c = sin(count)*1.1 - point * 0.01;
  float s = -0.4 + (snd * 0.8) - point * 0.01 * cos(count) * 0.1;

  vec2 size = vec2(resolution.x, resolution.y);
  vec2 xy = vec2(c, s);
  gl_Position = vec4(xy, 0, 1);

  float hue = (time * 0.01 + count * 1.001);
  //v_color = vec4(hsv2rgb(vec3(hue, 1, 1)), 1);
  v_color = (soundPoint.r < 0.1)
    ? vec4(0)
    : vec4(soundPoint.r * 0.7, soundPoint.g * 0.4 + 0.6, soundPoint.b * 0.8, 1);
  float pointSize = (count > 20.0) ? 10.0 : 30.0;
  gl_PointSize = soundPoint.r * (soundPoint.r + 0.2) * pointSize - 1.0;
}
