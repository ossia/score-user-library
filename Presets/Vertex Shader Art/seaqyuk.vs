/*{
  "DESCRIPTION": "seaqyuk",
  "CREDIT": "gman (ported from https://www.vertexshaderart.com/art/Xr5DemAP52ZcKLRbQ)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 95635,
  "PRIMITIVE_MODE": "LINES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.25098039215686274,
    0.25098039215686274,
    0.25098039215686274,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 965,
    "ORIGINAL_LIKES": 5,
    "ORIGINAL_DATE": {
      "$date": 1597671585559
    }
  }
}*/

#define PI radians(180.)

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

float p1m1(float v) {
  return v * 0.5 + 0.5;
}

float inv(float v) {
  return 1. - v;
}

void main() {
  float segmentsPerCircle = 64.0;
  float pointsPerCircle = segmentsPerCircle * 2.0;
  float numCircles = floor(vertexCount / pointsPerCircle);

  float vId = mod(vertexId, pointsPerCircle);
  float cId = floor(vertexId / pointsPerCircle);
  float cv = cId / numCircles;
  float u = floor(vId / 2.0) + mod(vId, 2.0);
  float v = u / segmentsPerCircle;
  float a = v * PI * 2.0 + cv;

  vec2 p = vec2(
    cos(a),
    sin(a));

  float distFromCenter = length(p);

  float s = texture(sound, vec2(
    mix(0.01, 0.1, abs(v * 2. - 1.)),
    abs(cv * 2. - 1.) * 1.0)
        ).r;

  float cvv = cv * 2. - 1.;
  vec3 pos = vec3(
      sin(cvv * PI * 0.5),
      p * mix(0., 1., sin(cv * PI)) * s);

  float ct = time * 0.1;
  vec3 eye = vec3(sin(ct), 0, cos(ct)) * 2.5;
  vec3 target = vec3(0, 0, 0);
  vec3 up = vec3(0, 1, 0);

  mat4 mat = persp(45. * PI / 180., resolution.x / resolution.y, 0.001, 10.);
  mat *= cameraLookAt(eye, target, up);
  gl_Position = mat * vec4(pos, 1);

  float boost = step(0.7, s);

  float hue = (time * 0.01) + pow(s, 3.) * 0.2 + boost * 0.5;
  float sat = 1.0 - pow(pos.z, 1.) - pow(s, 4.);
  float val = mix(0.25, 2.0, pow(s, 2.));
  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), 1);
}
// Removed built-in GLSL functions: transpose, inverse