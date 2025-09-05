/*{
  "DESCRIPTION": "msh",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/hFWjmNANJteP9NeAy)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 100000,
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
    "ORIGINAL_VIEWS": 405,
    "ORIGINAL_LIKES": 2,
    "ORIGINAL_DATE": {
      "$date": 1463104537706
    }
  }
}*/

/*

vertexshaderart

*/
#define PI radians(180.)

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

// hash function from https://www.shadertoy.com/view/4djSRW
float hash(float p)
{
 vec2 p2 = fract(vec2(p * 5.3983, p * 5.4427));
    p2 += dot(p2.yx, p2.xy + vec2(21.5351, 14.3137));
 return fract(p2.x * p2.y * 95.4337);
}

mat4 rotX(float angle) {

    float s = sin( angle );
    float c = cos( angle );

    return mat4(
      1, 0, 0, 0,
      0, c, s, 0,
      0,-s, c, 0,
      0, 0, 0, 1);
}

mat4 rotY( float angle ) {
    float s = sin( angle );
    float c = cos( angle );

    return mat4(
      c, 0,-s, 0,
      0, 1, 0, 0,
      s, 0, c, 0,
      0, 0, 0, 1);
}

mat4 rotZ( float angle ) {
    float s = sin( angle );
    float c = cos( angle );

    return mat4(
      c,-s, 0, 0,
      s, c, 0, 0,
      0, 0, 1, 0,
      0, 0, 0, 1);
}

mat4 trans(vec3 trans) {
  #if 0
  return mat4(
    1, 0, 0, trans[0],
    0, 1, 0, trans[1],
    0, 0, 1, trans[2],
    0, 0, 0, 1);
  #else
  return mat4(
    1, 0, 0, 0,
    0, 1, 0, 0,
    0, 0, 1, 0,
    trans, 1);
  #endif
}

mat4 ident() {
  return mat4(
    1, 0, 0, 0,
    0, 1, 0, 0,
    0, 0, 1, 0,
    0, 0, 0, 1);
}

mat4 uniformScale(float s) {
  return mat4(
    s, 0, 0, 0,
    0, s, 0, 0,
    0, 0, s, 0,
    0, 0, 0, 1);
}

mat4 scale(vec3 s) {
  return mat4(
    s[0], 0, 0, 0,
    0, s[1], 0, 0,
    0, 0, s[2], 0,
    0, 0, 0, 1);
}

mat4 persp(float fov, float aspect, float zNear, float zFar) {
  float f = tan(PI * 0.5 - 0.5 * fov);
  float rangeInv = 1.0 / (zNear - zFar);

  return mat4(
    f / aspect, 0, 0, 0,
    0, f, 0, 0,
    0, 0, (zNear + zFar) * rangeInv, -1,
    0, 0, zNear * zFar * rangeInv * 2., 0);
}

mat4 trInv(mat4 m) {
  mat3 i = mat3(
    m[0][0], m[1][0], m[2][0],
    m[0][1], m[1][1], m[2][1],
    m[0][2], m[1][2], m[2][2]);
  vec3 t = -i * m[3].xyz;

  return mat4(
    i[0], t[0],
    i[1], t[1],
    i[2], t[2],
    0, 0, 0, 1);
}

mat4 lookAt(vec3 eye, vec3 target, vec3 up) {
  vec3 zAxis = normalize(eye - target);
  vec3 xAxis = normalize(cross(up, zAxis));
  vec3 yAxis = cross(zAxis, xAxis);

  return mat4(
    xAxis, 0,
    yAxis, 0,
    zAxis, 0,
    eye, 1);
}

mat4 cameraLookAt(vec3 eye, vec3 target, vec3 up) {
  #if 1
  return inverse(lookAt(eye, target, up));
  #else
  vec3 zAxis = normalize(target - eye);
  vec3 xAxis = normalize(cross(up, zAxis));
  vec3 yAxis = cross(zAxis, xAxis);

  return mat4(
    xAxis, 0,
    yAxis, 0,
    zAxis, 0,
    -dot(xAxis, eye), -dot(yAxis, eye), -dot(zAxis, eye), 1);
  #endif

}

float m1p1(float v) {
  return v * 2. - 1.;
}

float p1m1(float v) {
  return v * .5 + .5;
}

float inRange(float v, float minV, float maxV) {
  return step(minV, v) * step(v, maxV);
}

float at(float v, float target) {
  return inRange(v, target - 0.1, target + 0.1);
}

void main() {
  float across = floor(sqrt(vertexCount * resolution.x / resolution.y));
  float down = floor(vertexCount / across);

  float gx = mod(vertexId, across);
  float gy = floor(vertexId / across);

  float u = gx / (across - 1.);
  float v = gy / (down - 1.);
  float c = u;
  float s = 1. - pow(1. - p1m1(sin(time * 0.2 + c * PI * 2. + PI * 0.5)), 4.);
  s = s * p1m1(sin(u * p1m1(sin(time * 0.111)) * 2.1));

  float x = u * 2. - 1.;
  float y = m1p1(fract(v + mix(-1., 1., mod(gx, 2.)) * time * 0.02 * m1p1(1. - u))) * 4.;

  x += sin(time * 0.09 + y * (p1m1(sin(time * 0.123)) + 0.1) * 10.) * 0.1;

  float snd = 0.;
  const int cnt = 12;
  for (int i = 0; i < cnt; ++i) {
   snd += texture(sound, vec2(p1m1(x) * 0.1, float(i) * 666. / IMG_SIZE(sound).y + p1m1(sin(PI * 2. * fract(p1m1(y)))))).r;
  }
  snd /= float(cnt);

  vec3 p = vec3(x, y, -1.5 + s * 1.);

  mat4 m = persp(radians(125.), 1. + 0. * resolution.x / resolution.y, 0.1, 10.);
  m *= rotZ(time * -0.01 + u);

  gl_Position = m * vec4(p, 1.);

  float hue = p1m1(s) * 0.4 + time * 0.02;
  float sat = 0.5 + snd;
  float val = 1. - snd * 0.5;
  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), 1);
  gl_PointSize = resolution.x / across * 0.5 / pow(abs(p.z), 1.4);
}

// Removed built-in GLSL functions: transpose, inverse