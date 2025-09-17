/*{
  "DESCRIPTION": "rpl",
  "CREDIT": "gman (ported from https://www.vertexshaderart.com/art/9MHkQW36H4sMgEA4e)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Geometry",
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 100000,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "CSS",
  "BACKGROUND_COLOR": [
    1,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 377,
    "ORIGINAL_LIKES": 6,
    "ORIGINAL_DATE": {
      "$date": 1556018472896
    }
  }
}*/

/*

  _ _ _____ __ __ _______ _____ __ __ ______ __ __ _____ _____ _____ __ __ _____ __ __ _______
 /_/\ /\_\ /\_____\/_/\__/\ /\_______)\ /\_____\/\ /\ /\/ ____/\ /\_\ /_/\ /\___/\ /\ __/\ /\_____\/_/\__/\ /\___/\ /_/\__/\ /\_______)\
 ) ) ) ( (( (_____/) ) ) ) )\(___ __\/( (_____/\ \ \/ / /) ) __\/( ( (_) ) ) / / _ \ \ ) ) \ \( (_____/) ) ) ) ) / / _ \ \ ) ) ) ) )\(___ __\/
/_/ / \ \_\\ \__\ /_/ /_/_/ / / / \ \__\ \ \ / / \ \ \ \ \___/ / \ \(_)/ // / /\ \ \\ \__\ /_/ /_/_/ \ \(_)/ //_/ /_/_/ / / /
\ \ \_/ / // /__/_\ \ \ \ \ ( ( ( / /__/_ / / \ \ _\ \ \ / / _ \ \ / / _ \ \\ \ \/ / // /__/_\ \ \ \ \ / / _ \ \\ \ \ \ \ ( ( (
 \ \ / /( (_____\)_) ) \ \ \ \ \ ( (_____\/ / /\ \ \)____) )( (_( )_) )( (_( )_) )) )__/ /( (_____\)_) ) \ \( (_( )_) ))_) ) \ \ \ \ \
  \_\_/_/ \/_____/\_\/ \_\/ /_/_/ \/_____/\/__\/__\/\____\/ \/_/ \_\/ \/_/ \_\/ \/___\/ \/_____/\_\/ \_\/ \/_/ \_\/ \_\/ \_\/ /_/_/

*/

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

#define NUM_EDGE_POINTS_PER_CIRCLE 256.
#define NUM_SUBDIVISIONS_PER_CIRCLE 2.
#define NUM_POINTS_PER_DIVISION (NUM_EDGE_POINTS_PER_CIRCLE * 6.)
#define NUM_POINTS_PER_CIRCLE (NUM_SUBDIVISIONS_PER_CIRCLE * NUM_POINTS_PER_DIVISION)
void getCirclePoint(const float id, const float inner, const float start, const float end, out vec3 pos, out vec2 uv) {
  float edgeId = mod(id, NUM_POINTS_PER_DIVISION);
  float ux = floor(edgeId / 6.) + mod(edgeId, 2.);
  float vy = mod(floor(id / 2.) + floor(id / 3.), 2.); // change that 3. for cool fx
  float sub = floor(id / NUM_POINTS_PER_DIVISION);
  float subV = sub / (NUM_SUBDIVISIONS_PER_CIRCLE - 1.);
  float level = subV + vy / (NUM_SUBDIVISIONS_PER_CIRCLE - 1.);
  float u = ux / NUM_EDGE_POINTS_PER_CIRCLE;
  float v = mix(inner, 1., level);
  float a = mix(start, end, u) * PI * 2. + PI * 0.0;
  float s = sin(a);
  float c = cos(a);
  pos = vec3(c, v, s);
  uv = vec2(u, v);//vec2(floor(edgeId / 6.) / NUM_EDGE_POINTS_PER_CIRCLE, subV);
}

float goop(float t) {
  return sin(t) + sin(t * 0.27) + sin(t * 0.13) + sin(t * 0.73);
}

void main() {
  float circleId = floor(vertexId / NUM_POINTS_PER_CIRCLE);
  float pointId = mod(vertexId, NUM_POINTS_PER_CIRCLE);
// float sideId = floor(circleId / 2.);
// float side = mix(-1., 1., step(0.5, mod(circleId, 2.)));
  float numCircles = floor(vertexCount / NUM_POINTS_PER_CIRCLE);
  float cu = circleId / numCircles;
  vec3 pos;
  float edgeId = mod(vertexId, NUM_POINTS_PER_DIVISION);
  float ux = floor(edgeId / 6.) + mod(edgeId, 2.);
  float u = ux / NUM_EDGE_POINTS_PER_CIRCLE;
  float u2 = floor(edgeId / 6.) / NUM_EDGE_POINTS_PER_CIRCLE;
  float st = fract(cu + time);
  float invSt = 1.0 - st;
  float inner = 0.0;//mix(0.5, 1.0, pow(snd + .3, 5.0));//0.9; //mix(0.0, 0.5, p1m1(sin(goop(circleId) + time * 0.1)));
  float start = fract(hash(circleId * 0.33));
  float end = start + 1.;//start + hash(sideId + 1.);
  vec2 uv;
  getCirclePoint(pointId, inner, start, end, pos, uv);

  float snd = texture(sound, vec2(mix(0.0, 0.25, uv.x), st * 0.25)).r;

  vec3 offset = vec3(t2m1(hash(circleId * floor(time * 1.2) * 0.123)), t2m1(hash(circleId * 0.37)), -t2m1(circleId / numCircles));
  //offset = vec3(0);
  float aspect = resolution.x / resolution.y;

  mat4 mat = persp(radians(45.0), aspect, 0.1, 1000.0);
  vec3 eye = vec3(0, 2, 7);
  vec3 target = vec3(0, -1, 0);
  vec3 up = vec3(0, 1, 0);
  mat4 view = cameraLookAt(eye, target, up);

  mat *= view;
// mat *= trans(offset);
  //float sc = (1. - pow(invSt, 1.2)) * 6.;
  float sc = st * 6.;
  mat *= scale(vec3(sc, snd * invSt, sc));
  mat *= trans(vec3(0, -0.5, 0));
  gl_Position = mat * vec4(pos, 1);
  gl_PointSize = 4.;

  float hue = fract(circleId);//, 1., step(0.75, snd));
  float sat = 1.;
  float val = mod(circleId, 2.0);// 1.0;pow(snd + .2, 5.) * invSt;
  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), invSt * 2.);
  //v_color = vec4(v_color.rgb * v_color.a, v_color.a);
}
// Removed built-in GLSL functions: transpose, inverse