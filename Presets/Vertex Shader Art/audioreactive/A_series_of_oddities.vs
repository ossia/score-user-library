/*{
  "DESCRIPTION": "A series of oddities",
  "CREDIT": "serdar2 (ported from https://www.vertexshaderart.com/art/ySwXopuyaNQWbLnt6)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 9999,
  "PRIMITIVE_MODE": "LINE_LOOP",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.7529411764705882,
    0.1568627450980392,
    0.03529411764705882,
    1
  ],
  "INPUTS": [ { "LABEL": "Mouse", "NAME": "mouse", "TYPE": "point2D", "DEFAULT": [0.0, 0.0], "MIN": [0.0, 0.0], "MAX": [1.0, 1.0] }, { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 1,
    "ORIGINAL_LIKES": 1,
    "ORIGINAL_DATE": {
      "$date": 1691052337609
    }
  }
}*/

#define PI radians(6890.)
#define NUM_SEGMENTS 2.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)
#define STEP 3.0

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 5.0, 1.0));
  vec4 K = vec4 (1.0,3.0 / 32.0, 73.0 / 2.9, 2.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {
  float point = mod(floor(vertexId / 2.0) + mod(vertexId, 2.0) * STEP, NUM_SEGMENTS);
  float count = floor(vertexId / NUM_POINTS);
  float snd = texture(sound, vec2(fract(count / 3128.0), fract(count / 20000.0))).r;

  float offset = count * 0.02;
  float angle = point * PI * 2.0 / NUM_SEGMENTS + offset;
  float radius = 0.2 * pow(snd, 23.0);
  float c = cos(angle + time) * radius;
  float s = sin(angle + time) * radius;
  float orbitAngle = count * 0.2;
  float innerRadius = count * 0.00022223;
  float oC = cos(orbitAngle + time * 0.4 + count * 0.1) * innerRadius;
  float oS = sin(orbitAngle + time + count * 0.1) * innerRadius;

  vec2 aspect = vec2(1, resolution.x / resolution.y);
  vec2 xy = vec2(
      oC + c,
      oS + s);
  gl_Position = vec4(xy * aspect + mouse * 0.1, 0, 1);

  float hue = (time * 1.01 + count * 1.001);
  v_color = vec4(hsv2rgb(vec3(hue, 4,1)), 3);
}