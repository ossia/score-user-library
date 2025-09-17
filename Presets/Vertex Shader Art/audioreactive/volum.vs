/*{
  "DESCRIPTION": "volum",
  "CREDIT": "gman (ported from https://www.vertexshaderart.com/art/s7zehgnGsLh5aHkM8)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
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
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 898,
    "ORIGINAL_LIKES": 12,
    "ORIGINAL_DATE": {
      "$date": 1484403657032
    }
  }
}*/

/*

Yea I know I need to sort it but I'm lazy :P

*/

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

void getQuadPoint(const float inId, out vec3 pos) {
  float id = mod(inId, 6.);
  float ux = floor(id / 6.) + mod(id, 2.);
  float vy = mod(floor(id / 2.) + floor(id / 3.), 2.); // change that 3. for cool fx
  pos = vec3(ux, 0, vy);
}

void main() {
  float numQuads = floor(vertexCount / 6.);
  float quadsPerAxis = floor(numQuads / 3.);
  float unitsPer = floor(pow(quadsPerAxis, 1. / 3.));
  float quadId = floor(vertexId / 6.);

  float qx = mod(quadId, unitsPer);
  float qy = mod(floor(quadId / unitsPer), unitsPer);
  float qz = mod(floor(quadId / unitsPer / unitsPer), unitsPer);

  float axisId = floor(quadId / quadsPerAxis);

  vec3 pos;
  getQuadPoint(vertexId, pos);

  float qu = qx / (unitsPer - 1.);
  float qv = qy / (unitsPer - 1.);
  float qw = qz / (unitsPer - 1.);

  float qa = qu * 2. - 1.;
  float qb = qv * 2. - 1.;
  float qc = qw * 2. - 1.;

  float v = length(vec3(qa, qb, qc)) * .2;
  float s = texture(sound, vec2(qb * 0.2, v)).r;

  float r = unitsPer * 1.3;
  float ctime = time * 0.1;
  vec3 eye = vec3(sin(ctime) * r, r + sin(ctime * 0.717) * r * 0.5, r);
  vec3 target = vec3(0); //vec3(sin(time * 0.17), sin(time * 0.13), -10);
  vec3 up = vec3(0,1,0); //vec3(sin(time * 0.3) * 0.2, 1, 0);

  mat4 mat = persp(40. * PI / 180., resolution.x / resolution.y, 0.1, 100.);
  mat *= cameraLookAt(eye, target, up);

  mat *= rotZ(axisId * PI * 0.5);
  mat *= rotY(step(1.5, axisId) * PI * 0.5);
  mat *= trans(vec3(qx, qy, qz) - vec3(unitsPer, unitsPer, unitsPer) * 0.5);

  gl_Position = mat * vec4(pos, 1);
  gl_PointSize = 4.;

  float hue = time * 0.1 + v + s * .2;
  float sat = 1.;
  float val = 1.;
  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), pow(s, 6.));
  v_color.rgb *= v_color.a;
}


// Removed built-in GLSL functions: transpose, inverse