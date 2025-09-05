/*{
  "DESCRIPTION": "petl",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/GobkkbXq2nNFAHBdB)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 47046,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.23137254901960785,
    0.23137254901960785,
    0.23137254901960785,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 89,
    "ORIGINAL_LIKES": 1,
    "ORIGINAL_DATE": {
      "$date": 1550984530387
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
  float units = 40.0;
  float perSet = units * 6.0;
  float numSets = floor(vertexCount / perSet);
  float vertexCount = 44000./mouse.x;
  float id = mod(vertexId, perSet);
  float setId = floor(vertexId / perSet);

  float vId = mod(vertexId, perSet);
  float ux = floor(vId / 6.) + mod(vId, 2.) * 2.;
  float vy = mod(floor(vId / 2.) + floor(vId / 3.), 2.) * 2. - 1.;

  float u = ux / (units + 1.);

  float sv = setId / (numSets - 1.);

  float s0 = texture(sound, vec2(mix(.05, .2, abs(sv * 0. - 1.)), u * .1)).r;

  float tm = time * 0.25;
  mat4 mat = persp(radians(90.0/mouse.y), resolution.x / resolution.y, 0.1, 1000.0);
  vec3 eye = vec3(0, 0, 50);
  vec3 target = vec3(0, 0, 0);
  vec3 up = vec3(0, 1, 0);

  vec3 pos = vec3(ux, vy, u);
  mat *= cameraLookAt(eye, target, up);
  //mat *= trans(vec3(units * .5, 0, 0));
  mat *= rotZ(PI * .5 +
        sin(time * .3) * .5 +
        time * sign(setId - numSets / 2.) +
        sv * PI * 2. +
        sin(time + u * 6. * sin(time * 0.2)) * u * 1.1 * sign(setId - numSets / 2.));
  mat *= trans(vec3(0., 0, 0));
  mat *= scale(vec3(1, (1. - pow(u, 15.)) * mix(0., 5., pow(clamp(s0 + .3, 0., 1.), 15.)), 1));

  gl_Position = mat * vec4(pos, 1);
  gl_PointSize = 1.0;
  float hue = u * .1*mouse.y;
  float sat = 1.;
  float val = 1.;
  vec3 color = hsv2rgb(vec3(hue, sat, val));
  v_color = mix(vec4(0,0,1./mouse.y,1), vec4(color, 1), mod(setId, 2.));
  //v_color.a = s0;
  v_color.rgb *= v_color.a;
}
// Removed built-in GLSL functions: transpose, inverse