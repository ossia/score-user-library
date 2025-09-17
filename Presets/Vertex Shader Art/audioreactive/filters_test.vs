/*{
  "DESCRIPTION": "filters test",
  "CREDIT": "ersh (ported from https://www.vertexshaderart.com/art/ewJGvmyLg4AN7sTJA)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [],
  "POINT_COUNT": 1024,
  "PRIMITIVE_MODE": "LINES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 1,
    "ORIGINAL_DATE": {
      "$date": 1689303550229
    }
  }
}*/

//test

#define NUM_SEGMENTS 128.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)
#define STEP 1.0
#define NUM_LINES_DOWN 4.0

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

float select(float v, float t) {
  return step(t * 0.9, v) * step(v, t * 1.1);
}

void main() {
  // produces 0,1, 1,2, 2,3, ...
  float point = floor(mod(vertexId, NUM_POINTS) / 2.0) + mod(vertexId, 2.0) * STEP;
  // line count
  float count = floor(vertexId / NUM_POINTS);

  float u = point / NUM_SEGMENTS; // 0 <-> 1 across line
  float v = count / NUM_LINES_DOWN; // 0 <-> 1 by line
  float invV = 1.0 - v;

  // Only use the left most 1/4th of the sound texture
  // because there's no action on the right
  float historyX = u * 0.25;
  // Match each line to a specific row in the sound texture
  float historyV = (0. * NUM_LINES_DOWN + 0.5) / IMG_SIZE(sound).y;
  float historyV2 = (1. * NUM_LINES_DOWN + 0.5) / IMG_SIZE(sound).y;
  float snd = texture(sound, vec2(historyX, historyV)).r;
  float snd2 = texture(sound, vec2(historyX, historyV2)).r;

  float s_norm = select(count, 0.);
  float s_low = select(count, 1.);
  float s_high = select(count, 2.);
  float s_powd = select(count, 3.);

  float ds = abs(snd - snd2);
  float norm = snd;
  float low = step(ds, 0.1) * snd;
  float high = step(0.1, ds) * snd;
  float powd = pow(snd, 5.0);

  float s =
    norm * s_norm +
    low * s_low +
    high * s_high +
    powd * s_powd +
    0.;

  float x = u * 2.0 - 1.0;
  float y = v * 2.0 - 1.0;
  vec2 xy = vec2(
      x,
      s * 0.2 + v - 0.3);
  gl_Position = vec4(xy, 0, 1);

  float hue = count * 0.25;
  float sat = 1.0;
  float val = 1.0;
  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), 1);
}