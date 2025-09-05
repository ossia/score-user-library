/*{
  "DESCRIPTION": "starship",
  "CREDIT": "gman (ported from https://www.vertexshaderart.com/art/gqGmyfsEh6zDQWsvA)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Nature"
  ],
  "POINT_COUNT": 100000,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 1,
    "ORIGINAL_DATE": {
      "$date": 1551162909297
    }
  }
}*/

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

float inv(float v) {
  return 1. - v;
}

void main() {
  float starId = floor(vertexId / 3.0);

  float near = 0.01;
  float far = 25.0;
  mat4 pmat = persp(radians(60.0), resolution.x / resolution.y, near, far);
  mat4 cmat = ident();
  cmat *= rotX(mouse.y * PI);
  cmat *= rotY(mouse.x * -PI);
  mat4 vmat = inverse(cmat);

  float starSize = 0.05;
  vec3 pos = vec3(
      hash(starId * 0.123),
      hash(starId * 0.357),
  // fract(hash(vertexId * 0.531) - time * .01)) * vec3(2, 2, -40) - vec3(1, 1, -20);
      fract(hash(starId * 0.531) + time * .05)) * 2. - 1.;
  pos *= 20.;

  pos += cmat[0].xyz * mod(vertexId, 2.) * starSize +
        cmat[1].xyz * step(1.5, mod(vertexId, 3.)) * starSize;

  vec3 boxMin = (cmat * vec4(-1, -1, 0, 1)).xyz;
  vec3 boxMax = (cmat * vec4(1, 1, -20, 1)).xyz;

  /*

  +--------+--------+--------+--------+
  | | | | |
  | |\ | | |
  | | \ | | |
  | | \ | | |
  +--------+--------+--------+--------+
  | | \ | | |
  | | \ | | |
  | | \ | | |
  | | \| | |
  +--------+--------c--------+--------+
  | | /| | |
  | | / | | |
  | | / | | |
  | | / | | |
  +--------+--------+--------+--------+
  | | / | | |
  | | / | | |
  | |/ | | |
  | | | | |
  +--------+--------+--------+--------+

  */

  //mat[2][2] /= far;
  //mat[2][3] /= far;

  gl_Position = pmat * vmat * vec4(pos, 1);
 // gl_Position.z = gl_Position.z * gl_Position.w / far;

  /*
mat4 persp(float fov, float aspect, float zNear, float zFar) {
  float f = tan(PI * 0.5 - 0.5 * fov);
  float rangeInv = 1.0 / (zNear - zFar);

  return mat4(
    f / aspect, 0, 0, 0,
    0, f, 0, 0,
    0, 0, (zNear + zFar) * rangeInv, -1,
    0, 0, zNear * zFar * rangeInv * 2., 0);
}

   rangeInv = 1.0 / (near - far)
   rangnInv = 1.0 / (0.01 - 25.0)
   rangeInv = 1.0 / -24.99
   rangeInv = -0.040016006402561027

     -0.1 * (0.1 + 25.0) * -0.04001 + 1 * (0.1 * 25.0 * -0.04001) * 2 = -0.000996
     -20 * (0.1 + 25.0) * -0.04001 + 1 * (0.1 * 25.0 * -0.04001) * 2 = 0.1988

  */

  v_color = vec4(1);vec4(hsv2rgb(vec3(hash(vertexId * 0.237), 0.25, 1)), 1);
  v_color.rgb *= v_color.a;
// v_color = vec4(hsv2rgb(vec3(depth, 1, 1)), 1);
}
// Removed built-in GLSL functions: transpose, inverse