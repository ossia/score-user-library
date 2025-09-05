/*{
  "DESCRIPTION": "unnamed",
  "CREDIT": "pentan (ported from https://www.vertexshaderart.com/art/7wqyFQDCq6cmDzs4H)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 50000,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 1165,
    "ORIGINAL_LIKES": 3,
    "ORIGINAL_DATE": {
      "$date": 1449514652019
    }
  }
}*/

#define PI05 1.570796326795
#define PI 3.1415926535898

float hash(float x) {
  return fract(sin(x) * 43758.5453123);
}

vec3 rotX(vec3 p, float rad) {
  vec2 sc = sin(vec2(rad, rad + PI05));
  vec3 rp = p;
  rp.y = p.y * sc.y + p.z * -sc.x;
  rp.z = p.y * sc.x + p.z * sc.y;
  return rp;
}

vec3 rotY(vec3 p, float rad) {
  vec2 sc = sin(vec2(rad, rad + PI05));
  vec3 rp = p;
  rp.x = p.x * sc.y + p.z * sc.x;
  rp.z = p.x * -sc.x + p.z * sc.y;
  return rp;
}

vec3 rotZ(vec3 p, float rad) {
  vec2 sc = sin(vec2(rad, rad + PI05));
  vec3 rp = p;
  rp.x = p.x * sc.x + p.y * sc.y;
  rp.y = p.x * -sc.y + p.y * sc.x;
  return rp;
}

vec4 perspective(vec3 p, float fov, float near, float far) {
  vec4 pp = vec4(p, -p.z);
  pp.xy *= vec2(resolution.y / resolution.x, 1.0) / tan(radians(fov * 0.5));
  pp.z = (-p.z * (far + near) - 2.0 * far * near) / (far - near);
  return pp;
}

mat4 lookat(vec3 eye, vec3 look, vec3 up) {
  vec3 z = normalize(eye - look);
  vec3 x = normalize(cross(up, z));
  vec3 y = cross(z, x);
  return mat4(x.x, y.x, z.x, 0.0, x.y, y.y, z.y, 0.0, x.z, y.z, z.z, 0.0, 0.0, 0.0, 0.0, 1.0) *
    mat4(1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, -eye.x, -eye.y, -eye.z, 1.0);
}

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {
  float t = vertexId + time;
  vec4 p = vec4(0.0, 0.0, 0.0, 1.0);
  p.xyz = fract(sin(vec3(t, 0.0, t+0.25)) * 12345.6789);

  float snd = texture(sound, p.xz * vec2(0.75, 1.0)).r;

  p.y = pow(snd, 2.0);
  p.xz = p.xz * 2.0 - 1.0;

  float rt = time * 0.25;
  mat4 m = lookat(vec3(cos(rt) * 2.5, 1.0, sin(rt) * 1.5), vec3(0.0, 0.25, 0.0), vec3(0.0, 1.0, 0.0));
  p = m * p;

  vec4 pp = perspective(p.xyz, 60.0, 0.2, 4.0);

  gl_Position = pp;
  gl_PointSize = 10.0 / length(p.xyz);

  v_color = vec4(hsv2rgb(vec3(snd, 1.0, 1.0)), 1.0);
}

