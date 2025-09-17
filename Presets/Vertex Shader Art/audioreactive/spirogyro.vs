/*{
  "DESCRIPTION": "spirogyro",
  "CREDIT": "gman (ported from https://www.vertexshaderart.com/art/R9YtdbpwyPFwwKsix)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
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
    "ORIGINAL_VIEWS": 206,
    "ORIGINAL_DATE": {
      "$date": 1469189780152
    }
  }
}*/

#define NUM_SEGMENTS 400.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)
#define PI radians(180.0)
vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec2 spirograph(float u, float n1, float n2, float n3, float a, float b, float y, float z) {
  u *= PI * 2.0;
  float a1 = pow(abs(cos(y * u / 4.) / a), n2);
  float b1 = pow(abs(sin(z * u / 4.) / b), n3);
  float ab = a1 + b1;
  float r = pow(abs(ab), -1. / n1);

  float c1 = cos(u) * r;
  float s1 = sin(u) * r;

  return vec2(c1, s1);
}

float bloop(float v) {
  return sin(v * PI * 2.) * .5 + .5;
}

void main() {
  float numCircles = floor(vertexCount / NUM_POINTS);
  // produces 0,1, 1,2, 2,3, ...
  float point = floor(mod(vertexId, NUM_POINTS) / 2.0) + mod(vertexId, 2.0);
  float circleId = floor(vertexId / NUM_POINTS);

  float u = point / NUM_SEGMENTS;
  float v = circleId / numCircles;
  float invV = 1.0 - v;

  float tm = time * 0.05 - v;
  vec2 ra = spirograph(
    u,
    mix(-20., 20., bloop(tm * 0.6)), // n1
    mix(-20., 20., bloop(tm * 0.7)), // n2
    mix(-20., 20., bloop(tm * 0.8)), // n3
    mix( 1., 50., bloop(tm * 0.9)), // a
    mix( 1., 50., bloop(tm * 0.10)), // b
    mix( 1., 100., bloop(tm * 0.11)), // y
    mix( 1., 100., bloop(tm * 0.12))); // z

  vec2 xy = ra;
  float aspect = resolution.y / resolution.x;
  gl_Position = vec4(xy * 0.25, 0, v) * vec4(aspect, 1, 1, 1);

  float su = bloop(u * 3. + time * 0.25);
  float snd = texture(sound, vec2(mix(0.001, 0.1, su), v * 0.2)).r;
  snd *= mix(1.0, 1.3, su);

  float cs = pow(snd, 5.);
  float hue = time * 0.1 + v * 0.2 + cs * 0.2;
  float sat = mix(0.75, 1., cs);
  float val = mix(0.75, 1., cs);
  v_color = mix(vec4(hsv2rgb(vec3(hue, sat, val)), 1), background, 0.);
}