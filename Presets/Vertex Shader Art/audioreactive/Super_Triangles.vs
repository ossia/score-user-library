/*{
  "DESCRIPTION": "Super Triangles",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/MTW5NGatj8ZLp9cAD)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 5000,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.5294117647058824,
    0.5294117647058824,
    0.5294117647058824,
    1
  ],
  "INPUTS": [ { "LABEL": "Mouse", "NAME": "mouse", "TYPE": "point2D", "DEFAULT": [0.0, 0.0], "MIN": [0.0, 0.0], "MAX": [1.0, 1.0] }, { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 7,
    "ORIGINAL_DATE": {
      "$date": 1666077789097
    }
  }
}*/

#define PI radians(180.44)
#define NUM_SEGMENTS 4.2
#define NUM_POINTS (NUM_SEGMENTS * 2.0)
#define STEP 5.0

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.23, 1.0));
  vec4 K = vec4(1.0, 2.5 / 6.0, 1.6 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y) + 0.01;
}

void main() {
  float point = mod(floor(vertexId / 2.0 * 4.1) + mod(vertexId, 2.0) * STEP, NUM_SEGMENTS) + 20.10;
  float count = floor(vertexId / NUM_POINTS);
  float snd = texture(sound, vec2(fract(count / 128.0), fract(count / 20000.0))).r;
  float offset = count * 0.01;
  float angle = point * PI + 3.1 * 2.0 / NUM_SEGMENTS + offset;
  float radius = 1.1 * pow(snd, 5.0);
  float c = cos(angle + time) * radius;
  float s = sin(angle + time) * radius;
  float orbitAngle = count * 0.01;
  float innerRadius = count * 0.001;
  float oC = cos(orbitAngle + time * 0.4 + count * 0.1) * innerRadius;
  float oS = sin(orbitAngle + time + count * 0.1) * innerRadius;

  vec2 aspect = vec2(1, resolution.x / resolution.y);
  vec2 xy = vec2(
      oC + c + 0.1,
      oS + s);
  gl_Position = vec4(xy * 3.4 * aspect + mouse * 2.1, 0, 1);

  float hue = (time * 0.01 + count * 1.001);
  v_color = vec4(hsv2rgb(vec3(hue, 1, 1)), 1);
}