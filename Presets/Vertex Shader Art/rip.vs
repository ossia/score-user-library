/*{
  "DESCRIPTION": "rip",
  "CREDIT": "gman (ported from https://www.vertexshaderart.com/art/MgkDcnH4JMLmrHeHs)",
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
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 1,
    "ORIGINAL_DATE": {
      "$date": 1452007227898
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
    float s = 0.;//texture(sound, vec2(fract(p.x * 0.01), fract(p.y * .1))).r;
    return pow(s, 5.) * 0.3;
    return sin(p.y * 4.);
    return sin(p.x * PI) * sin(p.y * PI) * 0.5;
 float f;
 f = 0.5000*noise( p ); p = mr*p*2.02;
 f += 0.2500*noise( p ); p = mr*p*2.33;
 f += 0.1250*noise( p ); p = mr*p*2.01;
 f += 0.0625*noise( p ); p = mr*p*5.21;

 return f;///(0.9375)*smoothstep( 260., 768., p.y ); // flat at beginning
}

vec3 getQuadPoint(const float id, const float scale, const vec3 off) {
  float outId = mix(id, 8. - id, step(2.5, id));
  float ux = floor(outId / 6.) + mod(outId, 2.);
  float vy = mod(floor(outId / 2.) + floor(outId / 3.), 2.);
  vec3 pos = (vec3(ux, 0, vy) + off) * scale;
  pos.y += fbm(pos.xz) * 2.;
  return pos;
}

#define POINTS_PER_QUAD 6.
void main() {
  float quadPnt = mod(vertexId, 6.);
  float quadId = floor(vertexId / POINTS_PER_QUAD);
  float numQuads = floor(vertexCount / POINTS_PER_QUAD);
  float down = floor(sqrt(numQuads));
  float across = floor(numQuads / down);

  float qx = mod(quadId, across);
  float qz = floor(quadId / across);
  float qu = qx / across;
  float qv = qz / down;
  vec3 q = vec3(qx, 0, qz);

  float s = 8. / across;

  float nId = floor(quadPnt / 3.) * 3.;
  vec3 n0 = getQuadPoint(nId + 0., s, q);
  vec3 n1 = getQuadPoint(nId + 1., s, q);
  vec3 n2 = getQuadPoint(nId + 2., s, q);
  vec3 n = (cross(normalize(n1 - n0), normalize(n2 - n1)));// * mix(vec3(1,1,1), vec3(-1,-1,-1), step(2.5, nId));
  vec3 lightDir = normalize(vec3(-1, 1, -2));
  float l = abs(dot(n, lightDir));

  vec3 p = getQuadPoint(quadPnt, s, q);

  vec3 cameraPos = vec3(mouse.x * 4., mix(5., 1., p1m1(mouse.y)), -3);
  vec3 cameraTarget = vec3(0, 0, 3);
  vec3 cameraUp = vec3(0, 1, 0);

  mat4 m = persp(radians(45.), resolution.x / resolution.y, 0.1, 100.);
  m *= cameraLookAt(cameraPos, cameraTarget, cameraUp);
  m *= trans(vec3(-across / 2. * s, 0, 0));

  gl_Position = m * vec4(p, 1);

  float snd = texture(sound, vec2(p1m1(gl_Position.x) * 0.1 * 0.25, gl_Position.z * 0.1)).r;
  float hue = snd;//time * 0.01 + qu * 0.2;//1.;m1p1(n.z);
  float sat = .3;abs(n.z);
  float val = mix(0.5, 1., l);
  v_color = vec4(hsv2rgb(vec3(hue, sat, val)),1);
  //v_color = vec4(n * 0.5 + 0.5, 1);

  gl_PointSize = 10.0;
}
// Removed built-in GLSL functions: transpose, inverse