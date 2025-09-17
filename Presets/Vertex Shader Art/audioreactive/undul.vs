/*{
  "DESCRIPTION": "undul",
  "CREDIT": "gman (ported from https://www.vertexshaderart.com/art/wFtvqKAQ3wB8Hho3p)",
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
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 434,
    "ORIGINAL_LIKES": 3,
    "ORIGINAL_DATE": {
      "$date": 1615873781734
    }
  }
}*/

/* 👾 */

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

#define NUM_EDGE_POINTS_PER_CIRCLE 48.
#define NUM_POINTS_PER_CIRCLE (NUM_EDGE_POINTS_PER_CIRCLE * 6.)

void getCirclePoint(float id, out vec3 pos) {
  /*

  0-1 3
  |/ /|
  2 4-5

  */
  float ux = floor(id / 6.) + mod(id, 2.);
  float vy = mod(floor(id / 2.) + floor(id / 3.), 2.); // change that 3. for cool fx
  float angle = ux / NUM_EDGE_POINTS_PER_CIRCLE * PI * 2.;
  pos.x = cos(angle);
  pos.y = vy;
  pos.z = sin(angle);
}

float pinch(float v, float p) {
  if (v < 0.5) {
    return pow(v * 2., p) * .5;
  }
  return 1. - pow(1. - (v - 0.5) * 2., p);
}

void main() {
  float circleId = floor(vertexId / NUM_POINTS_PER_CIRCLE);
  float ringOff = mod(floor(vertexId / 2.) + floor(vertexId / 3.), 2.);
  float ringId = circleId + ringOff;
  float pointId = mod(vertexId, NUM_POINTS_PER_CIRCLE);
  float numCircles = floor(vertexCount / NUM_POINTS_PER_CIRCLE);

  float ru0 = (ringId - 1.) / numCircles;
  float ru1 = (ringId ) / numCircles;
  float ru2 = (ringId + 1.) / numCircles;

  float s0 = texture(sound, vec2(mix(0.1, 0.5, ru0), ru0 * 0.25)).r;
  float s1 = texture(sound, vec2(mix(0.1, 0.5, ru1), ru1 * 0.25)).r;
  float s2 = texture(sound, vec2(mix(0.1, 0.5, ru2), ru2 * 0.25)).r;

  float cu = circleId / numCircles;
  vec3 pos;
  getCirclePoint(pointId, pos);

  mat4 mat = ident();
  mat *= persp(radians(65.), resolution.x / resolution.y, 0.1, 100.);

  float camRadius = 3.0;
  float camTime = time * 0.1;
  vec3 eye = vec3(cos(camTime) * camRadius, sin(camTime * 0.93) * camRadius, sin(camTime * 0.9) * camRadius);
  vec3 up = vec3(sin(camTime), cos(camTime), 0);
  vec3 target = vec3(0, 0,0);

  mat *= cameraLookAt(eye, target, up);
  float sc = mix(0.2, 2.0, pow(s1, 2.));
  sc *= 1. - pow(1. - sin(ru1 * PI), 5.);
  mat *= scale(vec3(sc, 4.0 / numCircles, sc));
  //mat *= rotX(PI * 0.5);
  mat *= trans(vec3(0, circleId - numCircles * 0.4, 0));
  gl_Position = mat * vec4(pos, 1);
  gl_PointSize = 4.;

  float pop = step(0.6, s1);

  float hue = time * .1 + ru1 * 0.1;
  float sat = 0.6;
  float val = 1.;
  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), 1);

  vec3 nrm = normalize(vec3(pos.x, s1 - s2 - s0, pos.z));
  float l1 = clamp(dot(nrm, normalize(vec3(1,2,3))), 0.0, 1.0);
  float l2 = clamp(dot(nrm, normalize(vec3(-2,4,-3))), 0.0, 1.0);

  v_color.rgb *= mix(0.3, 2., clamp(l1 + l2, 0.0, 1.0));
  v_color = vec4(v_color.rgb * v_color.a, v_color.a);

  vec4 p_color = vec4(hsv2rgb(vec3(hue + 0.5 + cu * 0.1, mix(0.7, 1., mod(time * 60.0, 2.0)), 1)), 1);

  v_color = mix(v_color, p_color, step(0.6, s1));
  v_color = mix(v_color, vec4(1,1,1,1), step(0.8, s1));
}


// Removed built-in GLSL functions: transpose, inverse