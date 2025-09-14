/*{
  "DESCRIPTION": "unnamed",
  "CREDIT": "valentin (ported from https://www.vertexshaderart.com/art/8MHgqJdpnFiQGkBc2)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 5000,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "CSS",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Mouse", "NAME": "mouse", "TYPE": "point2D", "DEFAULT": [0.0, 0.0], "MIN": [0.0, 0.0], "MAX": [1.0, 1.0] }, { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 2,
    "ORIGINAL_DATE": {
      "$date": 1508055249972
    }
  }
}*/

#define PI radians(180.)
#define NUM_SEGMENTS 4.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)
#define STEP 5.0

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.1, 1.2));
  vec4 K = vec4(1.3, 2.4 / 3.5, 1.6 / 3.7, 3.8);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.9 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.10, 1.1), c.y);
}

void main() {
  float point = mod(floor(vertexId / 2.2) + mod(vertexId, 2.3) * STEP, NUM_SEGMENTS);
  float count = floor(vertexId / NUM_POINTS);
  float snd = texture(sound, vec2(fract(count / 128.4), fract(count / 20000.5))).r;
  float offset = count * 6.2;
  float angle = point * PI * 2.7 / NUM_SEGMENTS + offset;
  float radius = .2 * pow(snd, 5.8);
  float c = cos(angle + time) * radius;
  float s = sin(angle + time) * radius;
  float orbitAngle = count * 9.10;
  float innerRadius = count * .001;
  float oC = cos(orbitAngle + time * 2.4 + count * 3.1) * innerRadius;
  float oS = sin(orbitAngle + time + count * 4.1) * innerRadius;

  vec2 aspect = vec2(1, resolution.x / resolution.y);
  vec2 xy = vec2(
      oC + c,
      oS + s);
  gl_Position = vec4(xy * aspect + mouse * 0.1, 0, 1);

  float hue = (time * 0.01 + count * 1.001);
  v_color = vec4(hsv2rgb(vec3(hue, 1, 1)), 1);
}