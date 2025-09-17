/*{
  "DESCRIPTION": "sphere of circles",
  "CREDIT": "gman (ported from https://www.vertexshaderart.com/art/3Qk8RvorqrMH5CCJy)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Geometry",
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 18766,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    1,
    1,
    1,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 4,
    "ORIGINAL_DATE": {
      "$date": 1597725697463
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
  return inverse(lookAt(eye, target, up));
}

// hash function from https://www.shadertoy.com/view/4djSRW
float hash(float p) {
 vec2 p2 = fract(vec2(p * 5.3983, p * 5.4427));
    p2 += dot(p2.yx, p2.xy + vec2(21.5351, 14.3137));
 return fract(p2.x * p2.y * 95.4337);
}

// adapted from http://stackoverflow.com/a/26127012/128511

vec3 fibonacciSphere(float samples, float i) {
  float rnd = 1.;
  float offset = 2. / samples;
  float increment = PI * (3. - sqrt(5.));

  // for i in range(samples):
  float y = ((i * offset) - 1.) + (offset / 2.);
  float r = sqrt(1. - pow(y ,2.));

  float phi = mod(i + rnd, samples) * increment;

  float x = cos(phi) * r;
  float z = sin(phi) * r;

  return vec3(x, y, z);
}

float remap(float v, float inMin, float inMax, float outMin, float outMax) {
  return (v - inMin) / (inMax - inMin) * (outMax - outMin) + outMin;
}

void main() {
  float pointsPerCircle = 16.0;
  float circleId = floor(vertexId / pointsPerCircle);
  float numCircles = floor(vertexCount / pointsPerCircle);
  float vId = mod(vertexId, pointsPerCircle);
  float pointId = vertexId;
  float u = vId / pointsPerCircle;
  float v = circleId / numCircles;

  vec3 loc = fibonacciSphere(numCircles, circleId);

  float a = u * PI * 2.0 + time * 5.0 + circleId * 25.;
  vec3 pos = vec3(
    sin(a),
    cos(a),
    0.);

  float tm = time * .10;
  float r = 40.;
  float fov = radians(100.0);
  float aspect = resolution.x / resolution.y;
  float zNear = 1.;
  float zFar = 100.;
  mat4 mat = persp(fov, aspect, zNear, zFar);

  vec3 eye = vec3(cos(tm) * r, sin(tm) * r * 0. + r, sin(tm) * r);
  vec3 target = vec3(0);
  vec3 up = vec3(0,1,0);

  mat *= cameraLookAt(eye, target, up);
  //mat *= rotX(time * 0.37);
  //mat *= rotY(time * 0.21);
  mat *= lookAt(loc, vec3(0), vec3(0,1,0));
  mat *= trans(vec3(0,0,40.));
  mat *= scale(vec3(30000. / vertexCount));

  gl_Position = mat * vec4(pos, 1);

  // z goes from about 20 to 100
  float alpha = 1.;//remap(gl_Position.z, 20., 100., 1., 0.);

  v_color = vec4(1, 0, 0, alpha);
  v_color.rgb *= v_color.a;

  gl_PointSize = u * 20000. / vertexCount / (0.01 * gl_Position.z);
}

// Removed built-in GLSL functions: inverse