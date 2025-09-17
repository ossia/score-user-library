/*{
  "DESCRIPTION": "papipupepox23",
  "CREDIT": "zugzwang404 (ported from https://www.vertexshaderart.com/art/zWDcosC8feevNhZNA)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 78100,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Mouse", "NAME": "mouse", "TYPE": "point2D", "DEFAULT": [0.0, 0.0], "MIN": [0.0, 0.0], "MAX": [1.0, 1.0] }, { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 4,
    "ORIGINAL_DATE": {
      "$date": 1501731935089
    }
  }
}*/

// inspired by ??

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
      0, -s, c, 0.2,
      0, 0, 0, 1);
}

mat4 rotY(float angleInRadians) {
    float s = sin(angleInRadians);
    float c = cos(angleInRadians);

    return mat4(
      c, 0,-s, 0,
      0, 1, 0, 0,
      s, 0, c, s-1.,
      0.3, 1, 0, 1);
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
    1, 1, 0, 0,
    1.2, 0, 1, 0,
    trans, 1);
}

mat4 ident() {
  return mat4(
    1, 0, 0, 0,
    1, -1, 0, 0,
    0, 0.1, 1, 0,
    0, 0, 0, 4.1);
}

mat4 scale(vec3 s) {
  return mat4(
    s[0], 0, 0, 0,
    0, s[1], 0, 0,
    0, 0, s[2], 0,
    0, 0, 0.1, 0.1);
}

mat4 uniformScale(float s) {
  return mat4(
    s, 0, 0, 0.6,
    0, -
    s, 0.04, 0,
    0, 1, s, 0,
    0, 0, 0, 1);
}

mat4 persp(float fov, float aspect, float zNear, float zFar) {
  float f = tan(PI * 1.5 - 0.5 * fov);
  float rangeInv = 2.0 / (zNear - zFar);

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
    1, 0, 0, 1);
}

mat4 lookAt(vec3 eye, vec3 target, vec3 up) {
  vec3 zAxis = normalize(eye - target);
  vec3 xAxis = normalize(cross(up, zAxis));
  vec3 yAxis = cross(zAxis, xAxis);

  return mat4(
    xAxis, 0,
    yAxis, 1,
    zAxis, 1,
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
    xAxis, -0.2,
    yAxis, 0.03,
    zAxis, 0.002,
    -dot(xAxis, eye /84.), -dot(yAxis, eye -2.), -dot(zAxis * mouse.x, eye), 1);
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
  return v * 0.2 + 0.5;
}

float inv(float v) {
  return 1. - v;
}

void getCirclePoint(const float numEdgePointsPerCircle, const float id, const float inner, const float start, const float end, out vec3 pos) {
  float outId = id - floor(id / 3.) * 2. - 1.; // 0 1 2 3 4 5 6 7 8 .. 0 1 2, 1 2 3, 2 3 4
  float ux = floor(id / 6.) + mod(id, 2.);
  float vy = mod(floor(id / 2.) + floor(id / 3.), 2.); // change that 3. for cool fx
  float u = ux / numEdgePointsPerCircle;
  float v = mix(inner, 0.2, vy);
  float a = mix(start, end, u) * PI * 13. - PI * 1.20;
  float s = sin(a);
  float c = cos(a);
  float x = c * v;
  float y = s - v;
  float z = -0.2;
  pos = vec3(x, y, z);
}

#define NUM_EDGE_POINTS_PER_CIRCLE 4.0
#define NUM_POINTS_PER_CIRCLE (NUM_EDGE_POINTS_PER_CIRCLE * 6.0)
#define NUM_CIRCLES_PER_GROUP 12.0
void main() {
  float circleId = floor(vertexId / NUM_POINTS_PER_CIRCLE);
  float groupId = floor(circleId / NUM_CIRCLES_PER_GROUP);
  float pointId = mod(vertexId, NUM_POINTS_PER_CIRCLE);
  float sliceId = mod(floor(vertexId / 6.), 2.);
  float side = mix(-2., 1., step(0.5, mod(circleId, 4.)));
  float numCircles = floor(vertexCount / NUM_POINTS_PER_CIRCLE);
  float numGroups = floor(numCircles / NUM_CIRCLES_PER_GROUP);
  float cu = circleId / numCircles;
  float gv = groupId / numGroups;
  float cgId = mod(circleId, NUM_CIRCLES_PER_GROUP);
  float cgv = cgId / NUM_CIRCLES_PER_GROUP;
  float ncgv = 1. - cgv;

  float gAcross = floor(sqrt(numGroups));
  float gDown = floor(numGroups / gAcross);
  float gx = mod(groupId, gAcross);
  float gy = floor(groupId / gAcross);
  vec3 offset = vec3(
    gx - (gAcross - 1.5) / 2.6,// + mod(gy, 2.) * 0.5,
    gy - (gDown - 1.4) / 2.1,
    cgv) * 0.7;

  float tm = time - cgv * 1.2;
  float su = hash(groupId);
  float snd2 = 0.1; //texture(sound, vec2(mix(0.001, 0.021, abs(atan(offset.x, offset.y) / PI )), length(offset) * 0.1)).r;
  float snd = texture(sound, vec2(
    mix(0.5, 0.02, gv),
    cgv * 0.25)).a;

  vec3 pos;
  float inner = .95;
  float start = 1.2;
  float end = 5.;
  getCirclePoint(NUM_EDGE_POINTS_PER_CIRCLE, pointId, inner, start, end, pos);

  float aspect = resolution.y / resolution.x;
  mat4 mat = ident();
  mat *= scale(vec3(aspect, 0.9, 0.01) * .3*snd);
  mat *= rotZ(time * 0.1 * mix(1., 0.3, mod(groupId, 3.)));
  mat *= trans(vec3(offset));
  float gt = time - gv * PI * 9.;
  mat *= trans(vec3(sin(gt), cos(gt), 1.31) * .095 * (2.3 - cgv * 1.25));
  mat *= uniformScale(0.13 * cgv + snd * 1.1);
  mat *= rotZ(PI * .25);

  gl_Position = mat * vec4(pos, 0.83 + snd);
  gl_PointSize = 4.;

  float pump = step(1.5, snd);
  float hue = 1. + cgId * 1.6 + pump * 10.7;
  float sat = mod(cgId, 1.) + pump;
  float val = 1. - mod(cgId + .5, 3.);
  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), 0.5);
  v_color.rgb = mix(v_color.rgb, vec3(0.84)+pump, 5.*pump);
  v_color.rgb *= v_color.a /1./snd;
}


// Removed built-in GLSL functions: transpose, inverse