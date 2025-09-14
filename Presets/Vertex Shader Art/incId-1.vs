/*{
  "DESCRIPTION": "incId",
  "CREDIT": "zugzwang404 (ported from https://www.vertexshaderart.com/art/TFoeAMv4JnW8NxM4N)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Geometry",
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 98784,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    1,
    1,
    1,
    1
  ],
  "INPUTS": [ { "LABEL": "Volume", "NAME": "volume", "TYPE": "audioFloatHistogram" }, { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 1,
    "ORIGINAL_DATE": {
      "$date": 1498346424580
    }
  }
}*/

#define PI radians(180.)

/*
void main() {
  const int hist = 8;
  float s = 0.;
  for (int i = 0; i < hist; ++i) {
    s += texture(volume, vec2((vertexId + .5) / 4., (float(i) + .5) / IMG_SIZE(sound).y)).a *
      1.;//float(hist - i);
  }
// s /= float(hist * (hist - 1)) / 2.;
  s /= float(hist);

  gl_Position = vec4(
    mod(vertexId , 2.) - .5,
    floor(vertexId / 2.) - .5, 0, 1);
  gl_PointSize = s * resolution.y / 2.;

  v_color = vec4(hsv2rgb(vec3(vertexId / vertexCount, 1, 1)), 1);
}
*/

/*

Wait for the music to pump

*/

//KDrawmode=GL_TRIANGLES

#define parameter0 3.//KParameter0 0.>>1.
#define parameter1 1.//KParameter1 0.1>>1.
#define parameter2 1.//KParameter2 0.>>1.
#define parameter3 1.//KParameter3 0.5>>3.
#define parameter4 1.//KParameter4 0.>>1.
#define parameter5 1.//KParameter5 0.>>3.
#define parameter6 1.//KParameter6 0.>>2.
#define parameter7 1.//KParameter7 0.>>2.

#define PI radians(180.)

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0* parameter2, 2.0 / 3.0 / parameter1, 0.0 / 4.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

mat4 rotX(float angleInRadians) {
    float s = sin(angleInRadians);
    float c = cos(angleInRadians);

    return mat4(
      1, 0, 0, -1,
      parameter3, c, s, 1,
      0, -s, c, 0,
      0, parameter4, 0, 1);
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
      0, s*parameter4, 1, 0,
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

void getCirclePoint(const float numEdgePointsPerCircle, const float id, const float inner, const float start, const float end, out vec3 pos) {
  float outId = id - floor(id / 3.) * 2. - 1.; // 0 1 2 3 4 5 6 7 8 .. 0 1 2, 1 2 3, 2 3 4
  float ux = floor(id / 6.) + mod(id, 2.);
  float vy = mod(floor(id / 2.) + floor(id / 3.), 2.); // change that 3. for cool fx
  float u = ux / numEdgePointsPerCircle;
  float v = mix(inner, 1., vy);
  float a = mix(start, end, u) * PI * 2. + PI * 0.0;
  float s = sin(a);
  float c = cos(a);
  float x = c * v;
  float y = s * v;
  float z = 0.;
  pos = vec3(x, y, z);
}

#define CUBE_POINTS_PER_FACE 6.
#define FACES_PER_CUBE 6.
#define POINTS_PER_CUBE (CUBE_POINTS_PER_FACE * FACES_PER_CUBE)
void getCubePoint(const float id, out vec3 position, out vec3 normal) {
  float quadId = floor(mod(id, POINTS_PER_CUBE) / CUBE_POINTS_PER_FACE);
  float sideId = mod(quadId, 3.);
  float flip = mix(1., -1., step(2.5, quadId));
  // 0 1 2 1 2 3
  float facePointId = mod(id, CUBE_POINTS_PER_FACE);
  float pointId = mod(facePointId - floor(facePointId / 3.0), 6.0);
  float a = pointId * PI * 2. / 4. + PI * 0.25;
  vec3 p = vec3(cos(a), 0.707106781, sin(a)) * flip;
  vec3 n = vec3(0, 1, 0) * flip;
  float lr = mod(sideId, 2.);
  float ud = step(2., sideId);
  mat4 mat = rotX(lr * PI * 0.5);
  mat *= rotZ(ud * PI * 0.5);
  position = (mat * vec4(p, 1)).xyz;
  normal = (mat * vec4(n, 0)).xyz;
}

mat4 mixm(mat4 m1, mat4 m2, float m) {
 return mat4(
    mix(m1[0], m2[0], m),
    mix(m1[1], m2[1], m),
    mix(m1[2], m2[2], m),
    mix(m1[3], m2[3], m));
}

void main() {
  float pointId = vertexId;

  vec3 pos;
  vec3 normal;
  getCubePoint(pointId, pos, normal);
  float cubeId = floor(pointId / 36.);
  float numCubes = floor(vertexCount / 36.);
  float down = floor(sqrt(numCubes) * .5);
  float across = floor(numCubes / down);
  float cv = cubeId / numCubes;

  float uu = mod(cubeId, across);
  float vv = floor(cubeId / across);
  vec2 uv = vec2(uu, vv) / vec2(across, down);

// const int hist = 10;
// float s = 0.;
// for (int i = 0; i < hist; ++i) {
// s += texture(volume, vec2((2. + .5) / 4., (float(i) + .5) / IMG_SIZE(sound).y)).a *
// 1.;//float(hist - i);
// }
//// s /= float(hist * (hist - 1)) / 2.;
// s /= float(hist);
  float s = texture(sound, vec2(mix(0.05, .5, hash(cubeId * .723)), 0.)).r;

  float tm = time * 0.;
  float rd = 9.;
  mat4 pmat = persp(radians(110.0), resolution.x / resolution.y, 0.1, 100.0);
  vec3 eye = vec3(cos(tm) * rd, sin(tm * 0.9) * rd * 0.6, sin(tm) * rd);
  vec3 target = vec3(0);
  vec3 up = vec3(0,1,0);

  mat4 vmat = cameraLookAt(eye, target, up);

  mat4 mat = rotY(time * .1);
  mat *= lookAt(
    normalize(vec3(t2m1(hash(cubeId * 0.123)), t2m1(hash(cubeId * 1.632)), t2m1(hash(cubeId * 0.327)))) *
    mix(20., 24.1, s),
    vec3(sin(time * 4.), sin(time * 3.17), 0.) * 10. * s,
    vec3(0, 1, 0));

  mat4 mvmat = vmat * mat;

  vec3 npos = normalize(mvmat[3].xyz);

  float hue = mix(.0, time * 10., step(.8, s));
  float sat = mix(-1.0, 2.2, s);
  float val = 1.;//mix(1., 1., step(0.8, s));

  float areaS = 1. - (npos.z * .5 + .5);
  mat4 smat = scale(vec3(2, 2, pow(s, 5.) * 100. * areaS + 0.01));
  smat *= uniformScale(0.5);
  smat *= trans(vec3(0, 0, -1));

  gl_Position = pmat * mvmat * smat * vec4(pos, 1);
  vec3 n = normalize((mat * vec4(normal, 0)).xyz);

  vec3 lightDir = normalize(vec3(1, 0.1, 1));

  vec3 color = hsv2rgb(vec3(hue, sat, val));
  v_color = vec4(color * (dot(n, lightDir) * 0.5 + 0.5), 1);
  v_color.a = mix(0., 2., s);
}


// Removed built-in GLSL functions: transpose, inverse