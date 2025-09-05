/*{
  "DESCRIPTION": "raymarched cube - Inspired by wblut's experiments with ray marching point clouds https://twitter.com/wblut/status/856959757588070401",
  "CREDIT": "tdhooper (ported from https://www.vertexshaderart.com/art/zQMGMroYDChPD5qbu)",
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
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 694,
    "ORIGINAL_LIKES": 3,
    "ORIGINAL_DATE": {
      "$date": 1493207227500
    }
  }
}*/

// --------------------------------------------------------
// Spectrum colour palette
// IQ https://www.shadertoy.com/view/ll2GD3
// --------------------------------------------------------

vec3 pal( in float t, in vec3 a, in vec3 b, in vec3 c, in vec3 d ) {
    return a + b*cos( 6.28318*(c*t+d) );
}

vec3 spectrum(float n) {
    return pal( n, vec3(0.5,0.5,0.5),vec3(0.5,0.5,0.5),vec3(1.0,1.0,1.0),vec3(0.0,0.33,0.67) );
}

// --------------------------------------------------------
// HG_SDF https://www.shadertoy.com/view/Xs3GRB
// --------------------------------------------------------

float vmax(vec3 v) {
 return max(max(v.x, v.y), v.z);
}

// Box: correct distance to corners
float fBox(vec3 p, vec3 b) {
 vec3 d = abs(p) - b;
 return length(max(d, vec3(0))) + vmax(min(d, vec3(0)));
}

void pR(inout vec2 p, float a) {
 p = cos(a)*p + sin(a)*vec2(p.y, -p.x);
}

// --------------------------------------------------------
// Geometry
// --------------------------------------------------------

float map(vec3 p) {
   vec3 offset = vec3(
     cos(time),
       sin(time),
       cos(time * 2.)
    );
   p -= offset * .25;
   pR(p.xy, time);
   pR(p.zx, time * .5);

   return -fBox(p, vec3(.7));
}

// --------------------------------------------------------
// Raymarch
// --------------------------------------------------------

const float MAX_TRACE_DISTANCE = 10.;
const float INTERSECTION_PRECISION = .001;
const int NUM_OF_TRACE_STEPS = 10;

float trace(vec3 rayDir) {

   float currentDist = INTERSECTION_PRECISION * 2.;
   float rayLen = 0.;

 for(int i=0; i< NUM_OF_TRACE_STEPS ; i++ ){
  if (currentDist < INTERSECTION_PRECISION || rayLen > MAX_TRACE_DISTANCE) {
        break;
        }
     currentDist = map(rayDir * rayLen);
       rayLen += currentDist;
 }

   return rayLen;
}

// --------------------------------------------------------
// Seed points, camera, and display
// gman https://www.vertexshaderart.com/art/7TrYkuK4aHzLqvZ7r
// --------------------------------------------------------

#define PI radians(180.0)

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

mat4 rotX(float angleInRadians) {
    float s = sin(angleInRadians);
    float c = cos(angleInRadians);

    return mat4(
      1, 0, 0, 0,
      0, c, s, 0,
      0, -s, c, 0,
      0, 0, 0, 1);
}

mat4 rotY(float angleInRadians) {
    float s = sin(angleInRadians);
    float c = cos(angleInRadians);

    return mat4(
      c, 0,-s, 0,
      0, 1, 0, 0,
      s, 0, c, 0,
      0, 0, 0, 1);
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

void main() {
  float numQuads = floor(vertexCount / 6.);
  float around = 100.;
  float down = numQuads / around;
  float quadId = floor(vertexId / 6.);

  float qx = mod(quadId, around);
  float qy = floor(quadId / around);

  // 0--1 3
  // | / /|
  // |/ / |
  // 2 4--5
  //
  // 0 1 0 1 0 1
  // 0 0 1 0 1 1

  float edgeId = mod(vertexId, 6.);
  float ux = mod(edgeId, 2.);
  float vy = mod(floor(edgeId / 2.) + floor(edgeId / 3.), 2.);

  float qu = (qx + ux) / around;
  float qv = (qy + vy) / down;

  float r = sin(qv * PI);
  float x = cos(qu * PI * 2.) * r;
  float z = sin(qu * PI * 2.) * r;

  vec3 pos = vec3(x, cos(qv * PI), z);

  pos *= trace(pos);

  float tm = time * .5;
  float rd = 3.;
  mat4 mat = persp(PI * 0.25, resolution.x / resolution.y, 0.1, 100.);
  vec3 eye = vec3(
    cos(tm) * rd,
    cos(tm) * rd,
    sin(tm) * rd
  );
  vec3 target = vec3(0);
  vec3 up = vec3(0,1,0);

  mat *= cameraLookAt(eye, target, up);

  vec4 pos4 = mat * vec4(pos, 1);

  gl_Position = pos4;
  gl_PointSize = 4.;

  vec3 col = vec3(spectrum(vertexId / vertexCount));
  col *= smoothstep(rd*2., rd, pos4.z);
  v_color = vec4(col, 1.);

}
// Removed built-in GLSL functions: transpose, inverse