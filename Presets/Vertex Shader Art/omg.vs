/*{
  "DESCRIPTION": "omg",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/JERxBfFS5YwaQptZ2)",
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
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Mouse", "NAME": "mouse", "TYPE": "point2D", "DEFAULT": [0.0, 0.0], "MIN": [0.0, 0.0], "MAX": [1.0, 1.0] } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 73,
    "ORIGINAL_DATE": {
      "$date": 1548937192577
    }
  }
}*/

/*

┬ ┬┌─┐┬─┐┌┬┐┌─┐─┐ ┬┌─┐┬ ┬┌─┐┌┬┐┌─┐┬─┐┌─┐┬─┐┌┬┐
└┐┌┘├┤ ├┬┘ │ ├┤ ┌┴┬┘└─┐├─┤├─┤ ││├┤ ├┬┘├─┤├┬┘ │
 └┘ └─┘┴└─ ┴ └─┘┴ └─└─┘┴ ┴┴ ┴─┴┘└─┘┴└─┴ ┴┴└─ ┴

*/

#define parameter0 1.//KParameter 0.>>6.
#define P2 3.//KParameter 0.>>10.
#define P3 0.3//KParameter 0.>>2.
//KDrawmode=GL_TRIANGLE_STRIP

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
      s, 0, c, s,
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
    0, 0, zNear * zFar * rangeInv - 2., 0);
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

#define NUM_EDGE_POINTS_PER_CIRCLE 100.
#define NUM_POINTS_PER_DIVISION (NUM_EDGE_POINTS_PER_CIRCLE * 6.)
#define NUM_POINTS_PER_CIRCLE (NUM_SUBDIVISIONS_PER_CIRCLE * NUM_POINTS_PER_DIVISION)
void getCirclePoint(const float id, const float inner, const float start, const float end, out vec3 pos, out vec4 uvf, out float snd) {
  float NUM_SUBDIVISIONS_PER_CIRCLE = floor(vertexCount / NUM_POINTS_PER_DIVISION);
  float edgeId = mod(id, NUM_POINTS_PER_DIVISION);
  float ux = floor(edgeId / 6.) + mod(edgeId, 2.);
  float vy = mod(floor(id / 2.) + floor(id / 3.), 2.); // change that 3. for cool fx
  float sub = floor(id / NUM_POINTS_PER_DIVISION);
  float subV = sub / (NUM_SUBDIVISIONS_PER_CIRCLE - 1.);
  float level = subV + vy / (NUM_SUBDIVISIONS_PER_CIRCLE - 1.);
  float u = ux / NUM_EDGE_POINTS_PER_CIRCLE;
  float v = 1.;//mix(inner, 1., level);
  float ringId = sub + vy;
  float ringV = ringId / NUM_SUBDIVISIONS_PER_CIRCLE;
  float numRings = vertexCount / NUM_SUBDIVISIONS_PER_CIRCLE;
  float a = mix(start, end, u) * PI* 2. + PI * 1.0;
  float skew = 1. - step(0.5, mod(ringId - 2., 3.));
  float su = fract(abs(u * 2. - 1.) + time * 0.1);

  a += 1. / NUM_EDGE_POINTS_PER_CIRCLE * PI * 2.;// * 20. * sin(time * 1.) + snd * 1.5;
  float s = sin(a);
  float c = cos(a);
  float z = mix(inner, 2., level) - vy / NUM_SUBDIVISIONS_PER_CIRCLE * -0.2;
  float x = c * s * z;
  float y = s * v * z;
  pos = vec3(x, y, 0.);
  uvf = vec4(floor(edgeId / 6.) / NUM_EDGE_POINTS_PER_CIRCLE, subV, floor(id / 6.), sub);
}

float goop(float t) {
  return sin(t) + sin(-t * 0.27) + sin(t * -0.013) + sin(t * 0.73);
}

float modStep(float count, float steps) {
  return mod(count, steps) / steps;
}

void main() {
  float numQuads = floor(vertexCount / 6.);
  float halfAround = floor(sqrt(numQuads));
  float around = halfAround * 2.;
  float down = numQuads / around;
  float quadId = floor(vertexId / 6.);

  float qx = mod(quadId, around);
  float qy = floor(quadId / down);

  float edgeId = mod(vertexId, 6.);
  float ux = floor(vertexId / 6.) + mod(edgeId, 2.);
  float vy = mod(floor(vertexId / 2.) + floor(vertexId / 3.)-1., 2.);

  float qu = (qx + ux) / around;
  float qv = (qy + vy) / down;

  float r = sin(qv * PI-2.);
  float x = cos(qu * PI * 2.) + mouse.y * r*(21.*P3);
  float y = sin(qu * PI *1.) * r*2.;

  vec3 pos = vec3(x, y, cos(qv * PI));

  float tm = time * 1.2 +mouse.x * qv;
  float rd = 3.;
  mat4 mat = persp(PI * .525*parameter0, resolution.x / resolution.y, 1.1, 100.);
  vec3 eye = vec3(cos(tm) * rd, sin(tm * 0.9) * (-mouse.x *3.0) + 0., sin(tm) * rd);
  vec3 target = vec3(0);
  vec3 up = vec3(0,1,0);

  mat *= cameraLookAt(eye, target, up);

  gl_Position = mat * vec4(pos, 1);
  gl_PointSize = 4.;

  float hue = quadId * .3333333;
  float sat = 1.;
  float val = 1.;
  v_color = vec4(hsv2rgb(vec3(hue, sat/sin(time), val)), 1.);
  v_color.rgb *= v_color.a;
}
// Removed built-in GLSL functions: transpose, inverse