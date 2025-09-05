/*{
  "DESCRIPTION": "pulse",
  "CREDIT": "gman (ported from https://www.vertexshaderart.com/art/JnRaHZcXYv7WBhq5b)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 10000,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "CSS",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Background", "NAME": "background", "TYPE": "color", "DEFAULT": [ 0.25, 0.59, 0.9, 1.0 ] } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 581,
    "ORIGINAL_LIKES": 7,
    "ORIGINAL_DATE": {
      "$date": 1447309159819
    }
  }
}*/

#define PI 3.14159
#define NUM_SEGMENTS 51.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)
#define STEP 5.0
//#define FIT_VERTICAL

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {
  float point = mod(floor(vertexId / 2.0) + mod(vertexId, 2.0) * STEP, NUM_SEGMENTS);
  float count = floor(vertexId / NUM_POINTS);
  float offset = count * 0.02;
  float angle = point * PI * 2.0 / NUM_SEGMENTS - offset;
  float rPlus = pow(sin(time * 3. + -count * 0.05), 4.0);
  float radius = count * 0.02 + rPlus * 0.2 + 0.0;
  float c = cos(angle + time) * radius;
  float s = sin(angle + time) * radius;
  float orbitAngle = count * 0.00;
  float oRadius = count * 0.00;
  float oC = cos(orbitAngle + time * count * 0.01) * oRadius;
  float oS = sin(orbitAngle + time * count * 0.01) * oRadius;

  #ifdef FIT_VERTICAL
    vec2 aspect = vec2(resolution.y / resolution.x, 1);
  #else
    vec2 aspect = vec2(1, resolution.x / resolution.y);
  #endif

  vec2 xy = vec2(
      oC + c,
      oS + s);
  gl_Position = vec4(xy * aspect + mouse * 0.1, 0, 1);
  gl_PointSize = 2.0 + length(xy) * 20. * resolution.x / 1600.0;

  float hue = (time * 0.01 + count * 1.001);
  v_color = mix(vec4(hsv2rgb(vec3(hue, 1.- rPlus, 1.)), 1), background, length(xy) - rPlus);
}