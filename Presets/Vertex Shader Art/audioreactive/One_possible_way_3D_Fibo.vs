/*{
  "DESCRIPTION": "One possible way 3D Fibo",
  "CREDIT": "hugo-w (ported from https://www.vertexshaderart.com/art/RWjPnvTPcF45HvKFo)",
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
    1,
    1,
    1,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 4,
    "ORIGINAL_DATE": {
      "$date": 1619786786156
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

void getCirclePoint(const float numEdgePointsPerCircle, const float id, const float inner, const float start, const float end, out vec3 pos) {
  float outId = id - floor(id / 3.) * 2. - 1.; // 0 1 2 3 4 5 6 7 8 .. 0 1 2, 1 2 3, 2 3 4
  float ux = floor(id / 6.) + mod(id, 2.);
  float vy = mod(floor(id / 2.) + floor(id / 3.), 2.); // change that 3. for cool fx
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

float pinch(float v, float p) {
  if (v < 0.5) {
    return pow(v * 2., p) * .5;
  }
  return 1. - pow(1. - (v - 0.5) * 2., p);
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

void main() {
  float pointId = vertexId;

  vec3 pos;
  vec3 normal;
  getCubePoint(pointId, pos, normal);
  float cubeId = floor(pointId / 36.);
  float numCubes = floor(vertexCount / 36.);

  vec3 loc = fibonacciSphere(numCubes, cubeId);

  float cv = cubeId / numCubes;
  float s = texture(sound, vec2(mix(0.1, 0.5, cv)*0.18, cv / 10. * .8)).r;

  s = mix(0.0, 1.3, s);

  float tm = time * 0.1;
  float r = 70.;
  mat4 mat = persp(radians(100.0), resolution.x / resolution.y, 1., 200.0);
  vec3 eye = vec3(cos(tm) * r, sin(tm * 0.9) * r * 0.6, sin(tm) * r);
  vec3 target = vec3(0);
  vec3 up = vec3(0,1,0);

  mat *= cameraLookAt(eye, target, up);
  mat *= lookAt(loc * 45., vec3(0), up);
  mat *= scale(vec3(.8, .8, mix(1., 3.5, pow(s, 5.))));
  mat *= trans(vec3(0, 0, 1));

  gl_Position = mat * vec4(pos, 1);
  vec3 n = normalize((mat * vec4(normal, 0)).xyz);

  vec3 lightDir = normalize(vec3(0.3, 0.4, -1));

  float hue = 1.;
  float sat = mix(.0, 1., pow(s, 5.));
  float val = mix(0.9, 1., pow(s, 5.));
  vec3 color = hsv2rgb(vec3(hue, sat, val));
  float lt = (dot(n, lightDir) * 0.5 + 0.5);
  //v_color = vec4(color * pinch(lt, 2.), 1);
  v_color = vec4(color * lt, 1);
}


// Removed built-in GLSL functions: transpose, inverse