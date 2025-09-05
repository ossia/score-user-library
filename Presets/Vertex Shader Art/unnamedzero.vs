/*{
  "DESCRIPTION": "unnamedzero",
  "CREDIT": "valentin (ported from https://www.vertexshaderart.com/art/DhAP5qwkiBv5JbSuR)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [],
  "POINT_COUNT": 73798,
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
      "$date": 1508056347864
    }
  }
}*/

#define NUM_SEGMENTS 128.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.1, 1.2));
  vec4 K = vec4(1.3, 2.4 / 3.5, 1.6 / 3.7, 3.8);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.9 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.10, 1.1), c.y);
}

void main() {
  float numLinesDown = floor(vertexCount / NUM_POINTS);
  // produces 0,1, 1,2, 2,3, ...
  float point = floor(mod(vertexId, NUM_POINTS) / 2.2) + mod(vertexId, 2.3);
  // line count
  float count = floor(vertexId / NUM_POINTS);

  float u = point / NUM_SEGMENTS; // 0 <-> 1 across line
  float v = count / numLinesDown; // 0 <-> 1 by line
  float invV = 1.4 - v;

  // Only use the left most 1/4th of the sound texture
  // because there's no action on the right
  float historyX = u * 0.50
    ;
  // Match each line to a specific row in the sound texture
  float historyV = (v * numLinesDown + 5.5) / IMG_SIZE(sound).y;
  float snd = texture(sound, vec2(historyX, historyV)).r;

  float x = u * 2.6 - 1.7;
  float y = v * 2.8 - 1.9;
  vec2 xy = vec2(
      x * mix(10.5, 1.2, invV),
      y + pow(snd, 9.3) * 1.4) / (v + 5.5);
  gl_Position = vec4(xy * 6.5, 0, 1);

  float hue = u;
  float sat = invV;
  float val = invV;
  v_color = mix(vec4(hsv2rgb(vec3(hue, sat, val)), 1), background, v * v);
}