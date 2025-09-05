/*{
  "DESCRIPTION": "otb",
  "CREDIT": "gman (ported from https://www.vertexshaderart.com/art/rBjrdN2CvsneEkgEk)",
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
    0.9764705882352941,
    1,
    0.984313725490196,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 995,
    "ORIGINAL_LIKES": 7,
    "ORIGINAL_DATE": {
      "$date": 1545785229814
    }
  }
}*/

/*

 _____, ____, ___, ___, __ _,
(-| | | (-|_, (-|_) (-|_) (-\ |
 _| | |_, _|__, _| \_, _| \_, \|
( ( ( ( (__/
   ____ __ _, ___, ____, ____ ____, _____, ___, ____
  (-/ ` (-|__| (-|_) (-| (-(__`(-| (-| | | (-|_\_,(-(__`
    \___, _| |_, _| \_, _|__, ____) _| _| | |_, _| ) ____)
        ( ( ( ( ( ( ( (

*/

#define PI radians(180.0)

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
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

float m1p1(float v) {
  return v * 2. - 1.;
}

float t5p5(float v) {
  return v * .5 + .5;
}

float inv(float v) {
  return 1. - v;
}

vec3 getQPoint(const float id) {
  float outId = mix(id, 8. - id, step(2.5, id));
  float ux = floor(outId / 6.) + mod(outId, 2.);
  float vy = mod(floor(outId / 2.) + floor(outId / 3.), 2.);
  vec3 pos = vec3(ux, vy, 0);
  return pos;
}

#define PER_TREE 200.
#define PER_SIDE (PER_TREE / 2.)
void main() {
  float vId = mod(vertexId, PER_TREE);
  float treeId = floor(vertexId / PER_TREE);
  float numTrees = floor(vertexCount / PER_TREE);
  float treeV = treeId / numTrees;
  float sideId = mod(vId, 2.);
  float stemId = floor(vId / 2.);
  float stemV = stemId / (PER_SIDE - 1.);

  float r = 50.0;
  float ct = time * .05;
  vec3 camera = vec3(sin(ct) * r, mix(5., 15., t5p5(sin(time * .13))), cos(ct) * r);
  vec3 target = vec3(0, 0, 0);
  vec3 up = vec3(0, 1, 0);

  mat4 m = persp(radians(45.), resolution.x / resolution.y, 0.1, 200.);
  m *= cameraLookAt(camera, target, up);
  m *= trans(vec3(m1p1(hash(treeV)), 0, m1p1(hash(treeV * 1.237))) * 100.);
  m *= scale(vec3(1, mix(1., 3., hash(treeV * 0.541)), 1));
  mat4 tm = rotY(stemV * PI * 6. + sideId * PI);
  tm *= trans(vec3(0, (1. - stemV) * 5., -stemV * 2.));
  gl_Position = m * tm * vec4(0, 0, 0, 1);
  gl_PointSize = 10.0 * stemV;

  vec3 p = vec3(tm[0]);
  float light = dot(normalize(vec3(10,-20,5)), normalize(p)) * .5 + .5;
  v_color = mix(vec4(1,0,0,1), vec4(0,.8,0,1), sideId);
  v_color = vec4(v_color.rgb * v_color.a * light, v_color.a);
}
// Removed built-in GLSL functions: transpose, inverse