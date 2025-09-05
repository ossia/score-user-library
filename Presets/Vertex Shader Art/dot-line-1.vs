/*{
  "DESCRIPTION": "dot-line - It's important to note that vertexshaderart shaders are **NOT** the recommended way\nto do things in WebGL!! Like Shadertoy they are rather a puzzle. Solving problems\nwith both hands tied behind your back.\n\nIf I was to do this in un-restricted WebGL I'd put the data in a texture (as vsa is now)\n\nI'd then call `gl.drawArrays` with `gl.POINTS` to draw just the dots and call it again with `gl.LINES` to just draw the lines OR if I wanted thick lines I might call it with `gl.TRIANGLES` for the lines as is happening here. I also would probably not do so much math in GLSL but then again with only 64 points it probably doesn't matter.",
  "CREDIT": "gman (ported from https://www.vertexshaderart.com/art/sxuyK3fxSLJbouBDN)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 3096,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    1,
    1,
    1,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 657,
    "ORIGINAL_DATE": {
      "$date": 1511803132132
    }
  }
}*/

/*

Just a challenge to put both lines and dots in the same piece

Note: I should really not be using my cirlce funciton which
is generating a square from 24 vertices instead of 6 but
I'm lazy and maybe using the circle funciton will generate
some different results later.

*/

#define PI radians(180.)

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
  float v = mix(inner, 1.41421356237, vy);
  float a = mix(start, end, u) * PI * 2.;
  float s = sin(a);
  float c = cos(a);
  float x = c * v;
  float y = s * v;
  float z = 0.;
  pos = vec3(x, y, z);
}

#if 1
#define NUM_EDGE_POINTS_PER_CIRCLE 4.0
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

  float line = mod(circleId, 2.); // 1 if line, 0 if point

  vec3 pos;
  float inner = 0.;
  float start = 0.;
  float end = 1.;
  getCirclePoint(NUM_EDGE_POINTS_PER_CIRCLE, pointId, inner, start, end, pos);
  pos.z = line * .1;

  float g0 = (groupId ) / numGroups;
  float g1 = (groupId + 1.) / numGroups;

  float s0 = texture(sound, vec2(mix(.1, .5, g0), 0)).r;
  float s1 = texture(sound, vec2(mix(.1, .5, g1), 0)).r;

  #if 0
  float t = time * 0.1;
  s0 = sin(t + g0 * 20.) * .5;
  s1 = sin(t + g1 * 20.) * .5;
  #endif

  vec2 p0 = vec2(t2m1(g0) * .9, s0 - .5);
  vec2 p1 = vec2(t2m1(g1) * .9, s1 - .5);
  vec2 dif = p1 - p0;

  float aspect = resolution.x / resolution.y;
  mat4 mat = scale(vec3(1, aspect, 1));

  const float dotSize = .005;
  const float lineWidth = .001;

  mat *= trans(vec3(p0, 0));
  mat *= rotZ(atan(dif.x, dif.y) * line);
  mat *= scale(mix(vec3(dotSize, dotSize, 1), vec3(lineWidth, length(dif) * .5, 1), line));
  mat *= trans(vec3(0, line * 1.0, 0));
  mat *= rotZ(PI * .25);

  gl_Position = mat * vec4(pos, 1);
  gl_PointSize = 4.;

  float hue = time * .1 + gv * .2;
  float sat = 1. - line;
  float val = 1. - line * .5;
  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), 1);
  v_color.rgb *= v_color.a;
}

#endif
// Removed built-in GLSL functions: transpose, inverse