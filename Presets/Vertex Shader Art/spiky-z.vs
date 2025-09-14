/*{
  "DESCRIPTION": "spiky-z",
  "CREDIT": "gman (ported from https://www.vertexshaderart.com/art/oQwndAmHzdhn3TLGK)",
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
    1,
    1,
    1,
    1
  ],
  "INPUTS": [ { "LABEL": "Mouse", "NAME": "mouse", "TYPE": "point2D", "DEFAULT": [0.0, 0.0], "MIN": [0.0, 0.0], "MAX": [1.0, 1.0] }, { "LABEL": "Background", "NAME": "background", "TYPE": "color", "DEFAULT": [ 0.25, 0.59, 0.9, 1.0 ] }, { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 4,
    "ORIGINAL_DATE": {
      "$date": 1470511532816
    }
  }
}*/

// terrain

#define PI radians(180.0)

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

mat4 rotX(float angle) {

    float s = sin( angle );
    float c = cos( angle );

    return mat4(
      1, 0, 0, 0,
      0, c, s, 0,
      0,-s, c, 0,
      0, 0, 0, 1);
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
  #if 0
  return mat4(
    1, 0, 0, trans[0],
    0, 1, 0, trans[1],
    0, 0, 1, trans[2],
    0, 0, 0, 1);
  #else
  return mat4(
    1, 0, 0, 0,
    0, 1, 0, 0,
    0, 0, 1, 0,
    trans, 1);
  #endif
}

mat4 ident() {
  return mat4(
    1, 0, 0, 0,
    0, 1, 0, 0,
    0, 0, 1, 0,
    0, 0, 0, 1);
}

mat4 uniformScale(float s) {
  return mat4(
    s, 0, 0, 0,
    0, s, 0, 0,
    0, 0, s, 0,
    0, 0, 0, 1);
}

mat4 scale(vec3 s) {
  return mat4(
    s[0], 0, 0, 0,
    0, s[1], 0, 0,
    0, 0, s[2], 0,
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

float m1p1(float v) {
  return v * 2. - 1.;
}

float p1m1(float v) {
  return v * .5 + .5;
}

float inRange(float v, float minV, float maxV) {
  return step(minV, v) * step(v, maxV);
}

float at(float v, float target) {
  return inRange(v, target - 0.1, target + 0.1);
}

// terrain function from mars shader by reider
// https://www.shadertoy.com/view/XdsGWH
const mat2 mr = mat2 (0.84147, 0.54030,
       0.54030, -0.84147 );
float hash( in float n )
{
 return fract(sin(n)*43758.5453);
}
float noise(in vec2 x)
{
 vec2 p = floor(x);
 vec2 f = fract(x);

 f = f*f*(3.0-2.0*f);
 float n = p.x + p.y*57.0;

 float res = mix(mix( hash(n+ 0.0), hash(n+ 1.0),f.x),
     mix( hash(n+ 57.0), hash(n+ 58.0),f.x),f.y);
 return res;
}
float fbm( in vec2 p )
{

    float su = fract(p.x * 0.0125);
    float sv = (p.y + 0.5) / IMG_SIZE(sound).y;
    float st = sin(time * 0.01) * 10. * 0.;
    float su2 = fract(mix(sv * 13.8 + st, (sv + 1.) * 140.8 + st, su * 0.00349));
    float su3 = mix(0.005, 0.54, su2);
    float s = 0.;
    const int count = 8;
    for (int i = 0; i < count; ++i) {
      s += texture(sound, vec2(su3, (float(i * 1) + 0.5) / IMG_SIZE(sound).y)).r * float(count - i);
    }
    return pow(s / float((count * (count + 1)) / 2), 0.75);
}

vec3 getQuadPoint(const float id, const float scale, const vec3 off, out vec3 preScale) {
  float outId = mix(id, 8. - id, step(2.5, id));
  float ux = floor(outId / 6.) + mod(outId, 2.);
  float vy = mod(floor(outId / 2.) + floor(outId / 3.), 2.);
  preScale = vec3(ux, 0, vy) + off;
  vec3 pos = preScale * scale + vec3(0, fbm(preScale.xz), 0);
  return pos;
}

#define POINTS_PER_QUAD 6.
void main() {
  float quadPnt = mod(vertexId, 6.);
  float realQuadId = floor(vertexId / POINTS_PER_QUAD);
  float numQuads = floor(vertexCount / POINTS_PER_QUAD) / 2.;
  float quadId = mod(realQuadId, numQuads);
  float totalQuads = numQuads * 2.;
  float down = IMG_SIZE(sound).y;
  float across = floor(numQuads / down);

  float secondHalf = step(numQuads, realQuadId);

  float qx = mod(quadId, across);
  float qz = floor(quadId / across);
  float qu = qx / across;
  float qv = qz / down;
  vec3 q = vec3(qx, 0, qz);

  float s = 8. / across;

  vec3 preScale;
  float nId = floor(quadPnt / 3.) * 3.;
  vec3 n0 = getQuadPoint(nId + 0., s, q, preScale);
  vec3 n1 = getQuadPoint(nId + 1., s, q, preScale);
  vec3 n2 = getQuadPoint(nId + 2., s, q, preScale);
  vec3 n = (cross(normalize(n1 - n0), normalize(n2 - n1)));// * mix(vec3(1,1,1), vec3(-1,-1,-1), step(2.5, nId));
  vec3 lightDir = normalize(vec3(-1, 1, -2));
  float l = abs(dot(n, lightDir));

  vec3 p = getQuadPoint(quadPnt, s, q, preScale);
  p.y *= mix(1.00001, 1.0, secondHalf);
  p.y -= mix(0.200012, 0.2, secondHalf);

  float ct = time * 0.1;
  float ct2 = ct + 2.0;
// vec3 cameraPos = vec3(mouse.x * 4., mix(5., 1., p1m1(mouse.y)), -3);
  vec3 cameraPos = vec3(sin(ct) * 3., 1., cos(ct) * 10. + 10.);
  vec3 cameraTarget = vec3(sin(ct2) * 2., 0, cos(ct2) * 10. + 10.);
  vec3 cameraUp = normalize(vec3(sin(ct + 2.5) * 0.3, 1, 0));

  mat4 m = persp(radians(45.), resolution.x / resolution.y, 0.1, 100.);
  m *= cameraLookAt(cameraPos, cameraTarget, cameraUp);
  //m *= rotX(preScale.z * mix(-0.1, -0.5, sin(time * 0.01)));
  //m *= rotY(preScale.x * mix(-0.1, -0.5, sin(time * 0.011)));
  m *= trans(vec3(-across / 2. * s, 0, 0));

  gl_Position = m * vec4(p, 1);

  float hue = 0.5 + sin(time * 0.01) * 1.1 + qu * 0. + pow(p.y, 5.) * 0.5;//1.;m1p1(n.z);
  float sat = 1.;//pow(1. - p.y, 2.);//.3;abs(n.z);
  float val = mix(0.25, 1., pow(l, 0.5));

  sat -= secondHalf * 0.25;
  hue += secondHalf * 0.52;

  float punch = step(0.8, p.y);
  l = mix(l, 1., punch);

  float cback = 1. - pow(qv, 5.);
  float cacross = 1. - pow(abs(((preScale.x / across) * 2. - 1.)), 10.);
  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), 1.);
  v_color = mix(v_color, background, 1. - cback * cacross);
  v_color.rga *= v_color.a;

  //v_color = mix(vec4(0, 0, 0, 1), v_color, 1. - secondHalf);

  gl_PointSize = 10.0;
}
// Removed built-in GLSL functions: transpose, inverse