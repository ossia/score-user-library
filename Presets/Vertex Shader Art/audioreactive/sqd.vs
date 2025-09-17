/*{
  "DESCRIPTION": "sqd",
  "CREDIT": "gman (ported from https://www.vertexshaderart.com/art/C2Kzd3CnpNPtWHjRw)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 37500,
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
    "ORIGINAL_VIEWS": 47,
    "ORIGINAL_DATE": {
      "$date": 1550428768721
    }
  }
}*/


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

void main() {
  float across = 25.0;
  float down = 25.0;

  float per = 6.;
  float cId = floor(vertexId / per);
  float numC = floor(vertexCount / per);

  float perSet = across * down;
  float numSets = floor(numC / perSet);

  float maxSize = max(resolution.x / across, resolution.y / down);
  float minSize = 1.;min(resolution.x / across, resolution.y / down);

  float id = mod(cId, perSet);
  float setId = floor(cId / perSet);
  float sv = setId / (numSets - 1.);

  float x = mod(id, across);
  float y = floor(id / across);

  float u = x / (across - 1.0);
  float v = y / (down - 1.0);

  vec2 uv2 = vec2(u * 2. - 1., v * 2. - 1.);

  float vId = mod(vertexId, per);
  float ux = floor(vId / 6.) + mod(vId, 2.) * 2. - 1.;
  float vy = mod(floor(vId / 2.) + floor(vId / 3.), 2.) * 2. - 1.;
  vec3 pos = vec3(ux, vy, 0);

  float s0 = texture(sound, vec2(
      mix(0.01, 0.25, atan(abs(u * 2. - 1.), abs(v * 2. - 1.)) / PI),
      (1. - sv) * 0.1)).a;

  float tm = time * 0.25;
  mat4 mat = persp(radians(60.0), resolution.x / resolution.y, 0.1, 1000.0);
  vec3 eye = vec3(0, 0, 50);
  vec3 target = vec3(0, 0, 0);
  vec3 up = vec3(0, 1, 0);

  mat *= cameraLookAt(eye, target, up);
  mat *= rotZ(time * (1. - length(uv2)));
  mat *= trans(vec3(uv2 * 30., 0.));
  mat *= uniformScale(pow(s0, 5.) * mix(10., 0.25, (1. - sv)));
  mat *= rotZ(6.*s0*sign(uv2.x - uv2.y));

  gl_Position = mat * vec4(pos, 1);
  gl_PointSize = 1.0;
  v_color = mix(vec4(1,sv,0,1), vec4(1,0,0,1), step(0.9, s0));
  v_color.rgb *= v_color.a;
}
// Removed built-in GLSL functions: transpose, inverse