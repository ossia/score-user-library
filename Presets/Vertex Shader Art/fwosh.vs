/*{
  "DESCRIPTION": "fwosh",
  "CREDIT": "gman (ported from https://www.vertexshaderart.com/art/Bv7nLsmSbowtSoGpA)",
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
    "ORIGINAL_VIEWS": 1196,
    "ORIGINAL_LIKES": 11,
    "ORIGINAL_DATE": {
      "$date": 1510261911187
    }
  }
}*/

/*

🍩

*/

#define PI radians(180.00)

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

void getCirclePoint(const float numEdgePointsPerCircle, const float id, const float inner, const float start, const float end, out vec3 pos) {
  float outId = id - floor(id / 3.) * 2. - 1.; // 0 1 2 3 4 5 6 7 8 .. 0 1 2, 1 2 3, 2 3 4
  float ux = floor(id / 6.) + mod(id, 2.);
  float vy = mod(floor(id / 2.) + floor(id / 3.), 2.); // change that 3. for cool fx
  float u = ux / numEdgePointsPerCircle;
  float v = mix(inner, 1., vy);
  float a = mix(start, end, u) * PI * 2.;
  float s = sin(a);
  float c = cos(a);
  float x = c * v;
  float y = s * v;
  float z = 0.;
  pos = vec3(x, y, z);
}

#if 1
#define NUM_EDGE_POINTS_PER_CIRCLE 36.0
#define NUM_POINTS_PER_CIRCLE (NUM_EDGE_POINTS_PER_CIRCLE * 6.0)
#define NUM_CIRCLES_PER_GROUP 1.0
#define NUM_POINTS_PER_GROUP (NUM_POINTS_PER_CIRCLE * NUM_CIRCLES_PER_GROUP)
void main() {
  float circleId = floor(vertexId / NUM_POINTS_PER_CIRCLE);
  float groupId = floor(circleId / NUM_CIRCLES_PER_GROUP);
  float sliceId = mod(floor(vertexId / 6.), 2.);
  float side = mix(-1., 1., step(0.5, mod(circleId, 2.)));
  float numCircles = floor(vertexCount / NUM_POINTS_PER_CIRCLE);
  float numGroups = floor(numCircles / NUM_CIRCLES_PER_GROUP);
  float cu = circleId / numCircles;
  float cgId = mod(circleId, NUM_CIRCLES_PER_GROUP);
  float cgv = cgId / NUM_CIRCLES_PER_GROUP;
  float ncgv = 1. - cgv;

  #define TRIS_AROUND_CIRCLE (NUM_EDGE_POINTS_PER_CIRCLE * 2.)
  float cTriId = mod(floor(vertexId / 3.), TRIS_AROUND_CIRCLE);
  float cTriV = cTriId / TRIS_AROUND_CIRCLE;
  float id = mod(vertexId, NUM_POINTS_PER_GROUP);
  float outId = id - floor(id / 3.) * 2. - 1.; // 0 1 2 3 4 5 6 7 8 .. 0 1 2, 1 2 3, 2 3 4
  float ux = floor(id / 6.) + mod(id, 2.);
  float vy = mod(floor(id / 2.) + floor(id / 3.), 2.); // change that 3. for cool fx
  float u = ux / NUM_EDGE_POINTS_PER_CIRCLE;
  float v = mix(0., 1., vy);

  float gv = (groupId + vy) / numGroups;

  float tm = time - cgv * 0.2;
  float su = hash(groupId);
  float snd2 = 1.0; //texture(sound, vec2(mix(0.001, 0.021, abs(atan(offset.x, offset.y) / PI )), length(offset) * 0.1)).r;
  float snd = 1.0;
  float s = texture(sound, vec2(mix(0.1, mix(.1, .5, t5p5(sin(time * .1))), abs(cu * 2. - 1.)), abs(cu * 2. - 1.) * .1 + abs(cTriV * 2. - 1.) * .1)).r;

  float a = ux / NUM_EDGE_POINTS_PER_CIRCLE * PI * 2.;
  vec3 pos = vec3(cos(a), sin(a), 0);
  vec3 nrm = pos;

  float r = 4.;
  float ct = time * .15 * .0;
  vec3 eye = vec3(sin(ct) * r, 3. + sin(ct * 1.7) * 1., cos(ct) * r);
  vec3 target = vec3(0, -3, 0);
  vec3 up = vec3(sin(time * 0.3) * 0.2, 1, 0);

  mat4 mat = persp(120. * PI / 180., resolution.x / resolution.y, 0.1, 100.);
  mat *= cameraLookAt(eye, target, up);

  mat *= rotY(gv * PI * 2.);
  mat *= trans(vec3(5,0,0));
  mat *= uniformScale(mix(.2, 1., pow(s + .5, 5.)));

  gl_Position = mat * vec4(pos, 1);
  gl_PointSize = 4.;

  vec3 n = (mat * vec4(nrm, 0)).xyz;

  float hue = time * .1 + sin(gv) * 0.1 + cTriV * .1;
  float sat = pow(s, 1.);
  float val = 1.;
  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), 1);

  vec3 lightDir = normalize(vec3(sin(time)*1.,.1,0.1));
  float l = dot(n, lightDir) * .5 + .5;

  v_color.rgb *= mix(1., l, sat);
  v_color.rgb *= v_color.a;

  //v_color.rgb = n * .5 + .5;
}

#endif
// Removed built-in GLSL functions: transpose, inverse