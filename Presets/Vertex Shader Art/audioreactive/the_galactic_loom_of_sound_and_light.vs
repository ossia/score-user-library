/*{
  "DESCRIPTION": "the galactic loom of sound and light",
  "CREDIT": "visy (ported from https://www.vertexshaderart.com/art/j7v3Ha4S2hwxhSCi9)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 100000,
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
    "ORIGINAL_VIEWS": 1217,
    "ORIGINAL_LIKES": 2,
    "ORIGINAL_DATE": {
      "$date": 1446513741559
    }
  }
}*/

#define NUM_SEGMENTS 128.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)
#define STEP 2.0
#define NUM_LINES_DOWN 512.0

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {
  // produces 0,1, 1,2, 2,3, ...
  float point = floor(mod(vertexId, NUM_POINTS) / 2.0) + mod(vertexId, 2.0) * STEP;
  // line count
  float count = floor(vertexId / NUM_POINTS);

  float u = point / NUM_SEGMENTS; // 0 <-> 1 across line
  float v = count / NUM_LINES_DOWN; // 0 <-> 1 by line
  float invV = 1.0 - v;

  // because there's no action on the right
  float historyX = u * 0.25;
  // Match each line to a specific row in the sound texture
  float historyV = (v * NUM_LINES_DOWN + 0.5) / IMG_SIZE(sound).y*0.5;
  float snd = texture(sound, vec2(historyX*0.05, historyV)).r;

  float x = u * 2.0 - 1.0;
  float y = v * 8.0 - 1.0;

  float xx = 1.0;
  float yy = 1.0;

  vec2 xy = vec2(
      xx*x * mix(0.5, 1.0, invV),
      yy*y + pow(snd, 5.0) * 1.0) / (v + 0.5);
  gl_Position = vec4(xy * 1.0*cos(v*5.0+time*0.1), 0, 2.2);

  float hue = v*5.5;
  float sat = invV;
  float val = invV;
  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), 1);
}