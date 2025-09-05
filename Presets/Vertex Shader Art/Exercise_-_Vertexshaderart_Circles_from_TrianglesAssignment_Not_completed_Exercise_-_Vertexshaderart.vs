/*{
  "DESCRIPTION": "Exercise - Vertexshaderart : Circles from TrianglesAssignment Not completed: Exercise - Vertexshaderart : Circles from Triangles",
  "CREDIT": "minkicho (ported from https://www.vertexshaderart.com/art/sbPQY2SPAe2cbSP3K)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Geometry",
    "Math",
    "Animated",
    "Abstract"
  ],
  "POINT_COUNT": 100000,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.11372549019607843,
    0.10196078431372549,
    1,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 6,
    "ORIGINAL_DATE": {
      "$date": 1684727100654
    }
  }
}*/

// Minki Cho
// Circles from Triangles
// CS250 Spring 2022

#define PI radians(180.)

vec3 hsv2rgb(vec3 c)
{
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

#if 1
void main() {
  float pointId = vertexId;

  vec3 pos;
  vec3 normal;
  getCubePoint(pointId, pos, normal);
  float cubeId = floor(pointId / 36.);
  float numCubes = floor(vertexCount / 36.);
  float down = floor(sqrt(numCubes));
  float across = floor(numCubes / down);

  float cx = mod(cubeId, across);
  float cy = floor(cubeId / across);

  float cu = cx / (across - 1.);
  float cv = cy / (down - 1.);

  float ca = cu * 2. - 1.;
  float cd = cv * 2. - 1.;

  float tm = time * 0.1;
  mat4 mat = persp(radians(60.0), resolution.x / resolution.y, 0.1, 1000.0);
  vec3 eye = vec3(cos(tm) * 1., sin(tm * 0.9) * .1 + 1., sin(tm) * 1.);
  vec3 target = vec3(0);
  vec3 up = vec3(0,1,0);

  mat *= cameraLookAt(eye, target, up);
  mat *= trans(vec3(ca, 0, cd) * 2.);
  mat *= rotX(time + abs(ca) * 5.);
  mat *= rotZ(time + abs(cd) * 6.);
  mat *= uniformScale(0.03);

  gl_Position = mat * vec4(pos, 1);
  vec3 n = normalize((mat * vec4(normal, 0)).xyz);

  vec3 lightDir = normalize(vec3(0.3, 0.4, -1));

  float hue = abs(ca * cd) * 2.;
  float sat = mix(1., 0., abs(ca));
  float val = mix(1., 0.5, abs(cd));
  vec3 color = hsv2rgb(vec3(hue, sat, val));
  v_color = vec4(color * (dot(n, lightDir) * 0.5 + 0.5), 1);
}
#endif

#if 0
#define NUM_EDGE_POINTS_PER_CIRCLE 6.0
#define NUM_POINTS_PER_CIRCLE (NUM_EDGE_POINTS_PER_CIRCLE * 6.0)
#define NUM_CIRCLES_PER_GROUP 2.0
void main() {
  float circleId = floor(vertexId / NUM_POINTS_PER_CIRCLE);
  float groupId = floor(circleId / NUM_CIRCLES_PER_GROUP);
  float pointId = mod(vertexId, NUM_POINTS_PER_CIRCLE);
  float sliceId = mod(floor(vertexId / 6.), 2.);
  float side = mix(-1., 1., step(0.5, mod(circleId, 2.)));
  float numCircles = floor(vertexCount / NUM_POINTS_PER_CIRCLE);
  float numGroups = floor(numCircles / NUM_CIRCLES_PER_GROUP);
  float cu = circleId / numCircles;
  float gv = groupId / numGroups;
  float cgId = mod(circleId, NUM_CIRCLES_PER_GROUP);
  float cgv = cgId / NUM_CIRCLES_PER_GROUP;
  float ncgv = 1. - cgv;

  float gAcross = 64.;
  float gDown = floor(numGroups / gAcross);
  float gx = mod(groupId, gAcross);
  float gy = floor(groupId / gAcross);
  vec3 offset = vec3(
    gx - (gAcross - 1.) / 2. + mod(gy, 2.) * 0.5,
    gy - (gDown - 1.) / 2.,
    0) * 0.17;

  float tm = time - cgv * 0.2;
  float su = hash(groupId);
  float snd2 = 1.0; //texture(sound, vec2(mix(0.001, 0.021, abs(atan(offset.x, offset.y) / PI )), length(offset) * 0.1)).r;
  float snd = 1.0; texture(sound, vec2(
    mix(0.205, 0.001, gy / gDown),
    abs(gx / gAcross - 0.5) * 2. * 0.2)).a;

  vec3 pos;
  float inner = 0.;
  float start = 0.;
  float end = 1.;
  getCirclePoint(NUM_EDGE_POINTS_PER_CIRCLE, pointId, inner, start, end, pos);
  pos.z = cgv;

  vec3 eye = vec3(sin(time * 0.19) * 0.25, sin(time * 0.21) * 0.25, 2.5);
  vec3 target = vec3(sin(time * 0.17), sin(time * 0.13), -10);
  vec3 up = vec3(sin(time * 0.3) * 0.2, 1, 0);

  mat4 mat = persp(120. * PI / 180., resolution.x / resolution.y, 0.1, 100.);
  mat *= cameraLookAt(eye, target, up);
  mat *= rotZ(time * 0.0 * mix(-1., 1., mod(circleId, 2.)) + gy * 0.0 * sin(time * 0.1));//sign(offset.x));
  float sp = pow(snd, 5.0);

  mat *= rotZ(time * 0.01 * gy * 0. + PI * 0.5);
  mat *= trans(vec3(0, 0, gy * 0.1 + mod(circleId, 2.0) * 0.05));
  mat *= rotZ(gx / gAcross * PI * 2.);
  mat *= rotY(PI * 0.5);
  mat *= trans(vec3(0, 0, 1. - (1. - gy / gDown) * .4));
  mat *= uniformScale(0.05);

  gl_Position = mat * vec4(pos, 1);
  gl_PointSize = 4.;

  float hue = 1. + cgId * 0.1;
  float sat = 1.;
  float val = 1.;
  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), 1);
  v_color.rgb *= v_color.a;
}

#endif
// Removed built-in GLSL functions: transpose, inverse