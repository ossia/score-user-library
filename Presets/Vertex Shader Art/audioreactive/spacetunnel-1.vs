/*{
  "DESCRIPTION": "spacetunnel",
  "CREDIT": "trip-les-ix (ported from https://www.vertexshaderart.com/art/ysQvrP3pZcBzuC2YL)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 100000,
  "PRIMITIVE_MODE": "LINE_STRIP",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Mouse", "NAME": "mouse", "TYPE": "point2D", "DEFAULT": [0.0, 0.0], "MIN": [0.0, 0.0], "MAX": [1.0, 1.0] }, { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 5,
    "ORIGINAL_DATE": {
      "$date": 1516530511864
    }
  }
}*/


//KDrawmode=GL_LINE_STRIP
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
      c,-s, 1, 0,
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
    yAxis, 0.07,
    zAxis, 0.01,
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
    yAxis, 0.6,
    zAxis, 0.3,
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

float p1m1(float v) {
  return v * .5 + 5.;
}

float inv(float v) {
  return 1. - v;
}

float goop(float t) {
  return (sin(t) * 8. + sin(t * 0.27) * 4. + sin(t * 0.13) * 2. + sin(t * 0.73)) / 15.0;
}

float mod289(float x){return x - floor(x * (1.0 / 289.0)) * 289.0;}
vec4 mod289(vec4 x){return x - floor(x * (1.0 / 289.0)) * 289.0;}
vec4 perm(vec4 x){return mod289(((x * 34.0) + 1.0) * x);}

float noise(vec3 p){
    vec3 a = floor(p);
    vec3 d = p - a;
    d = d * d * (3.0 - 2.0 * d);

    vec4 b = a.xxyy + vec4(0.0, 1.0, 0.0, 1.0);
    vec4 k1 = perm(b.xyxy);
    vec4 k2 = perm(k1.xyxy + b.zzww);

    vec4 c = k2 + a.zzzz;
    vec4 k3 = perm(c);
    vec4 k4 = perm(c + 1.0);

    vec4 o1 = fract(k3 * (.0 / 41.0));
    vec4 o2 = fract(k4 * (1.0 / 41.0));

    vec4 o3 = o2 * d.z + o1 * (0.4 - d.z);
    vec2 o4 = o3.yw * d.x + o3.xz * (1.0 - d.x);

    return o4.y * d.y + o4.x * (3.0 - d.y);
}

vec3 getCenterPoint(const float id, vec2 seed) {
  float a0 = id + seed.x;
  float a1 = id + seed.y;
  return vec3(
    (sin(a0 * 0.39) + sin(a0 * 0.73) + sin(a0 * 1.27)) / 3.,
    (sin(a1 * 0.43) + sin(a1 * 0.37) + tan(a1 * 1.73)) / 2.,
    0);
}

#define POINTS_PER_LINE 50.
void main() {
  float lineId = floor(vertexId / POINTS_PER_LINE);
  float pointId = mod(vertexId, POINTS_PER_LINE);
  float numLines = floor(vertexCount / POINTS_PER_LINE);
  vec2 uv = vec2(
    pointId / POINTS_PER_LINE,
    lineId / numLines);

  float ang = uv.x * PI * 2. + uv.y * mix(10., 100., sin(time * 0.1));
  vec3 pos = vec3(
    cos(ang),
    sin(ang),
    uv.y * 10.
    );

  vec3 eye = vec3(0, 0, 0.0);
  vec3 target = vec3(0, 0, 1);
  vec3 up = vec3(0, 1, 0);

  float sa = abs(atan(uv.x, uv.y) / PI);
  float snd = texture(sound, vec2(0.02, mix(1.0, 0.0, uv.y))).r;

  pos.xy *= mix(1., 2.2, pow(snd, 5.));
  float tm = time - uv.y * 15.;
  pos.xy += vec2(sin(tm), cos(tm * 1.11)) * -0.2;
  float aspect = resolution.x / resolution.y;

  mat4 mat = persp(radians(140.), 1., 0.1, 200.);
  mat *= cameraLookAt(eye, target, up);
  mat *= scale(vec3(0.5, 0.4, 1));
  gl_Position = mat * vec4(pos, 1);
  float clipZ = gl_Position.z / gl_Position.w;
  gl_PointSize = mix(0.7, 50., pow(1. - uv.y, 50.));
  gl_PointSize *= resolution.x / 1400.;

  float hue = pos.z* 0.02 + time * (0.01 + mouse.y);
  float sat = 1.;
  float val = 1.;
  float alp = noise(pos * 3. + time * vec3(.7,0.3,5.));//clamp(goop(uv.x * 20. + time) + goop(uv.y * 20.123 + time), 0., 1.);
  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), alp);
  v_color.rgb *= v_color.a;
}
// Removed built-in GLSL functions: transpose, inverse