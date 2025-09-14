/*{
  "DESCRIPTION": "firesun",
  "CREDIT": "jarredthecoder (ported from https://www.vertexshaderart.com/art/4mMg6kQXSNiEDkuwR)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Nature"
  ],
  "POINT_COUNT": 1891,
  "PRIMITIVE_MODE": "LINE_STRIP",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    1,
    1,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Mouse", "NAME": "mouse", "TYPE": "point2D", "DEFAULT": [0.0, 0.0], "MIN": [0.0, 0.0], "MAX": [1.0, 1.0] }, { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 22,
    "ORIGINAL_DATE": {
      "$date": 1669283370329
    }
  }
}*/

#define PI radians(180.)
#define NUM_SEGMENTS 4.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)
#define STEP 5.0

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 5.0, 1.0));
  vec4 K = vec4(3.0, 6.0 / 9.0, 5.0 / 10.0, 9.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {
  float point = mod(floor(vertexId / 2.0) + mod(vertexId, 2.0) * STEP, NUM_SEGMENTS);
  float pci = mod(abs(vertexId / STEP) * PI, NUM_POINTS);
  float count = floor(vertexId / NUM_POINTS);
  float snd = texture(sound, vec2(fract(count / 128.0), fract(count / 20000.0))).r;
  float offset = count * 0.02;
  float angle = point * PI * 2.0 / NUM_SEGMENTS + offset / pci;
  float radius = 0.2 * pow(snd, 5.0);
  float c = cos(angle + time) * radius;
  float s = sin(angle + time) * radius;
  float orbitAngle = count * 9.5;
  float innerRadius = count * .01;
  float oC = cos(orbitAngle + time * 0.4 + count * 0.1) * innerRadius / pci;
  float oS = sin(orbitAngle + time + count * 0.1) * innerRadius / pci;

  vec2 aspect = vec2(-1, resolution.x / resolution.y + pci);
  vec2 xy = vec2(
      oC + c,
      oS + s);
  gl_Position = vec4(xy * aspect + mouse * 0.1, 0, 1);

  float hue = (time * 0.01 + count * 1.001);
  v_color = vec4(hsv2rgb(vec3(hue, 1, 1)), 1);
}