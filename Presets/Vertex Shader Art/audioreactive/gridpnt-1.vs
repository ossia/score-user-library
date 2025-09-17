/*{
  "DESCRIPTION": "gridpnt",
  "CREDIT": "tapos (ported from https://www.vertexshaderart.com/art/kQB2kyZz5geDYpNeo)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 100000,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "CSS",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 42,
    "ORIGINAL_LIKES": 1,
    "ORIGINAL_DATE": {
      "$date": 1703151823873
    }
  }
}*/

/*

 __ __ ______ ______ ______ ______ __ __ ______ __ __ ______ _____ ______ ______ ______ ______ ______
/\ \ / / /\ ___\ /\ == \ /\__ _\ /\ ___\ /\_\_\_\ /\ ___\ /\ \_\ \ /\ __ \ /\ __-. /\ ___\ /\ == \ /\ __ \ /\ == \ /\__ _\
\ \ \'/ \ \ __\ \ \ __< \/_/\ \/ \ \ __\ \/_/\_\/_ \ \___ \ \ \ __ \ \ \ __ \ \ \ \/\ \ \ \ __\ \ \ __< \ \ __ \ \ \ __< \/_/\ \/
 \ \__| \ \_____\ \ \_\ \_\ \ \_\ \ \_____\ /\_\/\_\ \/\_____\ \ \_\ \_\ \ \_\ \_\ \ \____- \ \_____\ \ \_\ \_\ \ \_\ \_\ \ \_\ \_\ \ \_\
  \/_/ \/_____/ \/_/ /_/ \/_/ \/_____/ \/_/\/_/ \/_____/ \/_/\/_/ \/_/\/_/ \/____/ \/_____/ \/_/ /_/ \/_/\/_/ \/_/ /_/ \/_/

*/

#define PI radians(180.0)

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
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

float inv(float v) {
  return 1. - v;
}

void main() {
  float size = floor(pow(vertexCount, 1./3.));
  float div = size - 1.;
  vec3 p = vec3(
    mod(vertexId, size),
    mod(floor(vertexId / size), size),
    floor(floor(vertexId / size) / size));

  vec3 snd = vec3(
    texture(sound, vec2(hash(vertexId / vertexCount / 3. + 0.1) * 0.25, 0.0)).r,
    texture(sound, vec2(hash(vertexId / vertexCount / 3. + 0.3) * 0.25, 0.0)).r,
    texture(sound, vec2(hash(vertexId / vertexCount / 3. + 0.5) * 0.25, 0.0)).r);

  float a = time * 0.01;
  float r = 1.0;
  float c = cos(a) * r;
  float s = sin(a) * r;
  float y = sin(time * 0.011);

  vec3 target = vec3(0,0,0);
  vec3 up = vec3(0,1,0);
  vec3 eye = vec3(c, y, s);

  mat4 m = ident();
  m *= persp(radians(45.), resolution.x / resolution.y, 0.1, 2.);
  m *= cameraLookAt(eye, target, up);
  m *= trans(vec3(-1, -1, -1));
  m *= uniformScale(2. / div);

  vec3 sp = snd * snd * snd * snd * snd * snd * snd * snd * snd;
  gl_Position = m * vec4(p + sp * .5, 1);

  float z = gl_Position.z * 0.5 + 0.5;
  float sm = max(max(sp.x, sp.y), sp.z);
  float hue = 1.;//(time * 0.01 + count * 1.001);
  v_color = vec4(mix(p / div * vec3(0,1,1) * z, vec3(1,0,0), step(0.7, sm)), mix(0.8,1.5, mod(floor(vertexId * 0.33 + time * 30.0), 2.)));
  v_color.r += snd.b;
  v_color.g += snd.g;
  v_color.b /= snd.r;

  v_color = vec4(hsv2rgb(v_color.rbg), v_color.b * 1.2);
  gl_PointSize = mix(10.3, 0.0, z) + step(0.7, sm) * 2.;
}
// Removed built-in GLSL functions: transpose, inverse