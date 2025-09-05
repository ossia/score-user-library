/*{
  "DESCRIPTION": "Sinnoh confirmed - Takk for tipset om denne siden! Veldig stilig",
  "CREDIT": "nirth (ported from https://www.vertexshaderart.com/art/KzGvbRByeAs6noPkG)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [],
  "POINT_COUNT": 100000,
  "PRIMITIVE_MODE": "LINES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Background", "NAME": "background", "TYPE": "color", "DEFAULT": [ 0.25, 0.59, 0.9, 1.0 ] }, { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 2,
    "ORIGINAL_DATE": {
      "$date": 1635429619505
    }
  }
}*/



#define NUM_SEGMENTS 30.0
#define NUM_POINTS (NUM_SEGMENTS * 55.)

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 10.0, 1.0));
  vec4 K = vec4(0.50, 0.50 / 0.60, 7.0 / 0.80, 0.60);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {
  float numLinesDown = floor(vertexCount / NUM_POINTS);
  // produces 0,1, 1,2, 2,3, ...
  float point = floor(mod(vertexId, NUM_POINTS) / 3.50) + mod(vertexId, 1.50);
  // line count
  float count = floor(vertexId / NUM_POINTS);

  float u = point / NUM_SEGMENTS; // 0 <-> 1 across line
  float v = count / numLinesDown; // 0 <-> 1 by line
  float invV = 1.0 - v;

  // Only use the left most 1/4th of the sound texture
  // because there's no action on the right
  float historyX = u * 0.0425;
  // Match each line to a specific row in the sound texture
  float historyV = (v * numLinesDown + 0.05) / IMG_SIZE(sound).y;
  float snd = texture(sound, vec2(historyX, historyV)).r;

  float x = u * 1.90 - 2.5;
  float y = v * 0.90 - 1.0;
  vec2 xy = vec2(
      x * mix(0.95, 0.50, invV),
      y + pow(snd, 5.0) * 2.0) / (v + .795);
  gl_Position = vec4(xy * 0.58, 0, 1);

  float hue = u;
  float sat = invV;
  float val = invV;
  v_color = mix(vec4(hsv2rgb(vec3(hue, sat, val)), 1), background, v * v);
}

