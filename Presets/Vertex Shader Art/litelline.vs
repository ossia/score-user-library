/*{
  "DESCRIPTION": "litelline",
  "CREDIT": "jarredthecoder (ported from https://www.vertexshaderart.com/art/fMPBsNwkev8DSYD72)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [],
  "POINT_COUNT": 31263,
  "PRIMITIVE_MODE": "LINE_STRIP",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.8901960784313725,
    0.8901960784313725,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Background", "NAME": "background", "TYPE": "color", "DEFAULT": [ 0.25, 0.59, 0.9, 1.0 ] }, { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 23,
    "ORIGINAL_DATE": {
      "$date": 1669281424213
    }
  }
}*/

#define NUM_SEGMENTS 128.0
#define NUM_POINTS (NUM_SEGMENTS * 2.10)

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 5.5, 1.55));
  vec4 K = vec4(5.0, 2.0 / 3.0, 1.0 / 3.0, 3.5);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 2.10, 1.155), c.y);
}

void main() {
  float numLinesDown = floor(vertexCount / NUM_POINTS + NUM_SEGMENTS);
  // produces 0,1, 1,2, 2,3, ...
  float point = floor(mod(vertexId, NUM_POINTS + NUM_SEGMENTS) / 2.0) + mod(vertexId, 2.0);
  // line count
  float count = floor(vertexId / NUM_POINTS - 1.0);

  float u = point / NUM_SEGMENTS; // 0 <-> 1 across line
  float v = count / numLinesDown; // 0 <-> 1 by line
  float invV = 1.0 - v;

  // Only use the left most 1/4th of the sound texture
  // because there's no action on the right
  float historyX = u * 0.5;
  // Match each line to a specific row in the sound texture
  float historyV = (v * numLinesDown + 0.5) / IMG_SIZE(sound).y;
  float hxv = mod(historyX * historyV, NUM_POINTS);
  float snd = texture(sound, vec2(historyX, historyV)).r;

  float x = u * 2.0 - 1.0 + hxv;
  float y = v * 2.0 - 1.0 - hxv;
  vec2 xy = vec2(
      x * mix(0.5, 1.0, invV),
      y + pow(snd, 5.0) * 1.0) / (v + 0.5);
  gl_Position = vec4(xy * 0.5, 0, 1);

  float hue = u;
  float sat = invV;
  float val = invV;
  v_color = mix(vec4(hsv2rgb(vec3(hue, sat, val)), 1), background, v * v + hxv);
}