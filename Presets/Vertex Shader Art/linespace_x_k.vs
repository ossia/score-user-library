/*{
  "DESCRIPTION": "linespace x k",
  "CREDIT": "zugzwang404 (ported from https://www.vertexshaderart.com/art/D4KsKHDFES8P7NEBc)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Geometry",
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 100000,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.19607843137254902,
    0.2627450980392157,
    0.49411764705882355,
    1
  ],
  "INPUTS": [ { "LABEL": "Background", "NAME": "background", "TYPE": "color", "DEFAULT": [ 0.25, 0.59, 0.9, 1.0 ] }, { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 146,
    "ORIGINAL_LIKES": 1,
    "ORIGINAL_DATE": {
      "$date": 1499769645193
    }
  }
}*/

/* 🐧

*/

#define parameter0 3.//KParameter0 -1.>>3.
#define parameter1 1.//KParameter1 0.1>>1.
#define parameter2 1.//KParameter2 0.>>1.
#define parameter3 1.//KParameter3 -0.5>>4.
#define parameter4 1.//KParameter4 0.>>1.
#define parameter5 1.//KParameter5 0.>>3.
#define parameter6 1.//KParameter6 0.>>1.
#define parameter7 1.//KParameter7 0.>>1.

#define PI radians(180.0)

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 3.03, 0.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, sin(22.0 -1.0) * 3.0, 0.2);
  vec3 p = abs(fract(c.xxx + K.xyz) * 116.0 / K.www / parameter0);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.20 * parameter1, 0.8), c.x +c.y);
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
      0, 1, 0, parameter3,
      s, 0, c, 0,
      0, 0, 0, 1);
}

mat4 rotZ(float angleInRadians) {
    float s = sin(angleInRadians);
    float c = cos(angleInRadians);

    return mat4(
      c,-s, 0, 0,
      s, c, 0, parameter3,
      0, 1, 1, 0,
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
    -0.2, 0, 0, 1);
}

mat4 scale(vec3 s) {
  return mat4(
    s[0], 1, 0, 0,
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
  vec3 zAxis = normalize(eye - target +parameter5);
  vec3 xAxis = normalize(cross(up, zAxis -parameter4));
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
    p2 += dot(p2.yx, p2.xy + vec2(21.5351, 14.3137 * parameter5));
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

vec3 getQuadStripPoint(const float id) {
  float ux = floor(id / 6.) + mod(id, 2.);
  float vy = mod(floor(id / 2.) + floor(id / 3.), 2.);
  return vec3(ux, vy, 0);
}

void getCirclePoint(const float numEdgePointsPerCircle, const float id, const float inner, const float start, const float end, out vec3 pos) {
  float ux = floor(id / 6.) + mod(id, 2.);
  float vy = mod(floor(id / 2.) + floor(id / 3. *parameter6), 2.); // change that 3. for cool fx
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

float Hash( vec2 p) {
     vec3 p2 = vec3(p.xy,1.0);
    return fract(sin(dot(p2,vec3(37.1,61.7, 12.4)))*3758.5453123*parameter7);
}

float noise(in vec2 p) {
    vec2 i = floor(p);
     vec2 f = fract(p);
     f *= f * (3.0-2.0*f);

    return mix(mix(Hash(i + vec2(0.,0.)), Hash(i + vec2(1.,0.)),f.x),
        mix(Hash(i + vec2(0.,1.)), Hash(i + vec2(1.,1.)),f.x),
        f.y);
}

float fbm(vec2 p) {
     float v = 0.0;
     v += noise(p*1.0)*.5* parameter1;
// v += noise(p*2.)*.25;
// v += noise(p*4.)*.125;
     return v;
}

float crv(float v) {
  return fbm(vec2(v, v * 1.23));
  //float o = sin(v) + sin(v * 2.1) + sin(v * 4.2) + sin(v * 8.9);
  //return o / 4.;
}

vec3 fgetCurvePoint(float t) {
// return vec3(sin(-t), sin(t * 0.8), sin(t * 0.6));
// return vec3( mod(t, 1.) * 0.01, 0, mod(t, 1.));
  return vec3(
    crv(t),
    crv(t + .3),
    crv(t + .6)
  ) * 2. - 1.;
}

vec3 getCurvePoint(const float id) {
  return vec3(
    sin(id * 0.99),
    sin(id * 2.43),
    sin(id * 1.57));
}

const float expand = 80.;

void sky(const float vertexId, const float vertexCount, float base, const mat4 cmat, out vec3 pos, out vec4 color) {
  float starId = floor(vertexId / 3.);
  float numStars = floor(vertexCount / 3.);
  float starV = starId / numStars;

  float h = hash(starId * 0.017);
  float s = texture(sound, vec2(
    mix(0.02, 0.5, h),
    mix(0.0, 0.05, starV))).a;

  float pId = mod(vertexId, 3.);
  float sz = pow(s + 0.25, 5.) * 10.;

  pos = normalize(vec3(
    t2m1(hash(starId * 0.123)),
    t2m1(hash(starId * 0.353)),
    t2m1(hash(starId * 0.627)))) * 500.;
  pos += cmat[0].xyz * sz * step(0.5, pId);
  pos += cmat[1].xyz * sz * step(1.5, pId);

  float hue = time * .1 + h * .2;
  float sat = 1.;
  float val = pow(s + 0.4, 5.);
  color = vec4(hsv2rgb(vec3(hue, sat, val)), 1);

  float pump = step(.8, s);
  color = mix(color, vec4(1, 0, 0, 1), pump);
  color.a = mix(1., 0.2, pow(s, 15.));
  color.rgb *= color.a;
}

void main() {
  const float numTrackPoints = 30000.0;
  const float numFunkPoints = 3600.0; // must be multiple of 3

  //float base = 15.; // good place to adjust
  float base = time * 0.125;

  const float coff = 0.14;

  vec3 b0 = getCurvePoint(base + coff * 0.);
  vec3 b1 = getCurvePoint(base + coff * 1.);
  vec3 b2 = getCurvePoint(base + coff * 2.);

  vec3 c0 = normalize(b1 - b0);
  vec3 c1 = normalize(b2 - b1);

  vec3 czaxis = normalize(c1 - c0);
  vec3 cxaxis = normalize(cross(c0, c1));
  vec3 cyaxis = normalize(cross(czaxis, cxaxis));

  mat4 pmat = persp(radians(60.0), resolution.x / resolution.y, .1, 1000.0);

  vec2 ms = vec2(0); //texture(touch, vec2(0, 0)).xy + vec2(0, 1);

  vec3 eye = b0 * expand + cyaxis * .001 + czaxis * 2.2;
  vec3 target = b1 * expand + cyaxis * .002 + czaxis + ms.x * cxaxis * 2. + ms.y * cyaxis * 40.;
  vec3 up = cyaxis;

  mat4 cmat = lookAt(eye, target, up);
  mat4 vmat = rotZ(asin(up.y) * 1.) * inverse(cmat);

  vec3 pos;
  vec4 color;

  sky(vertexId + 1., vertexCount - 1., base, cmat, pos, color);

  gl_Position = pmat * vmat * vec4(pos, 1);
  v_color = color;

  float cz = gl_Position.z / gl_Position.w * .5 + .5;
  v_color.rgb = mix(v_color.rgb, background.rgb, mix(4., 0.26, cz));

}

// Removed built-in GLSL functions: transpose, inverse