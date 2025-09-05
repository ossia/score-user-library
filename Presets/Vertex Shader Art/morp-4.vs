/*{
  "DESCRIPTION": "morp",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/o39WoEQsYbe48X2id)",
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
    1,
    1,
    1,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 88,
    "ORIGINAL_DATE": {
      "$date": 1627247667018
    }
  }
}*/

/* ⭕️⭕️⭕️⭕️⭕️⭕️⭕️

*/

#define PI radians(180.)

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 4.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

mat4 rotX(float angleInRadians) {
    float s = sin(angleInRadians);
    float c = cos(angleInRadians);

    return mat4(
      1, 02, 0, 0,
      0, c, s, 0,
      0, -s, c, 0,
      0, 0, 0, 12);
}

mat4 rotY(float angleInRadians) {
    float s = sin(angleInRadians);
    float c = cos(angleInRadians);

    return mat4(
      c, 0,-s, 0,
      0, 12, 0, 0,
      s, 0, c, 0,
      0, 0, 0, 12);
}

mat4 rotZ(float angleInRadians) {
    float s = sin(angleInRadians);
    float c = cos(angleInRadians);

    return mat4(
      c,-s, 0, 0,
      s, c, 0, 0,
      0, 0, 1, 0,
      0, 0, 0, 1);
}

mat4 trans(vec3 trans) {
  return mat4(
    1, 0, 0, 0,
    0, 1, 0, 0,
    0, 0, 1, 0,
    trans, 1);
}

mat4 ident() {
  return mat4(
    1, 0, 0, 0,
    0, 1, 0, 0,
    0, 0, 1, 0,
    0, 0, 0, 1);
}

mat4 scale(vec3 s) {
  return mat4(
    s[0], 0, 0, 0,
    0, s[1], 0, 0,
    0, 0, s[2], 0,
    0, 0, 0, 1);
}

mat4 uniformScale(float s) {
  return mat4(
    s, 0, 0, 0,
    0, s, 0, 0,
    0, 0, s, 0,
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

// hash function from https://www.shadertoy.com/view/4djSRW
float hash(float p) {
 vec2 p2 = fract(vec2(p * 5.3983, p * 5.4427));
    p2 += dot(p2.yx, p2.xy + vec2(21.5351, 14.3137));
 return fract(p2.x * p2.y * 95.4337);
}

// times 2 minus 1
float t2m1(float v) {
  return v * 2. - 1.;
}

// times .5 plus .5
float t5p5(float v) {
  return v * 0.5 + 0.5;
}

const float edgePointsPerCircle = 128.;
const float pointsPerCircle = edgePointsPerCircle * 2.;

void main() {
  float pointId = mod(vertexId, pointsPerCircle);
  float pId = floor(pointId / 2.) + mod(pointId, 2.);
  float numCircles = floor(vertexCount / pointsPerCircle);
  float circleId = floor(vertexId / pointsPerCircle);
  float numPairs = floor(numCircles / 2.);
  float pairId = floor(circleId / 2.);
  float pairV = pairId / numPairs;
  float pairA = t2m1(pairV);
  float odd = mod(pairId, 2.);

  float pV = pId / edgePointsPerCircle;
  float cV = circleId / numCircles;
  float cA = t2m1(cV);

  float a = pV * PI * 2.;
  float x = cos(a);
  float z = sin(a);

  vec3 pos = vec3(x, 0, z);
  vec3 normal;

  float tm = time * 0.1;
  float tm2 = time * 0.13;

  mat4 wmat = rotZ(odd * PI * .5 + sin(tm));
  wmat *= trans(vec3(0, cos(pairA * PI), 0));
  wmat *= uniformScale(sin(pairA * PI));
  vec4 wp = wmat * vec4(pos, 1.);

  float su = abs(atan(wp.x, wp.z)) / PI;
  float sv = abs(wp.y) * 1.;
  float s = texture(sound, vec2(mix(0.1, 0.5, su), sv)).r;
// float s = texture(sound, vec2(pairV, cV)).r;//
  wp.xyz *= mix(0.8, 1.2, pow(s, 1.));

  float r = 2.5;
  mat4 mat = persp(radians(60.0), resolution.x / resolution.y, 0.1, 10.0);
  vec3 eye = vec3(cos(tm) * r, sin(tm * 0.93) * r, sin(tm) * r);
  vec3 target = vec3(0);
  vec3 up = vec3(0., sin(tm2), cos(tm2));

  mat *= cameraLookAt(eye, target, up);

  gl_Position = mat * wp;

  vec3 color = mix(
     vec3(0.5, 0, 0),
     vec3(0, 0, 0.5),
     gl_Position.x);
  v_color = vec4(color, mix(.0, 1., pow(1. -sv, 2.)));
  v_color.rgb *= v_color.a;
}


// Removed built-in GLSL functions: transpose, inverse