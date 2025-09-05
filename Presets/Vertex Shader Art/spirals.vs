/*{
  "DESCRIPTION": "spirals",
  "CREDIT": "gman (ported from https://www.vertexshaderart.com/art/AZFnk3yzLiSZ2KkWS)",
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
    1,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 140,
    "ORIGINAL_DATE": {
      "$date": 1467321349369
    }
  }
}*/

/* 👻 */

#define PI radians(180.0)

// from: http://lolengine.net/blog/2013/07/27/rgb-to-hsv-in-glsl

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

float easeInOutCubic(float pos, float power) {
  pos *= 2.;
  if (pos < 1.) {
    return 0.5 * pow(pos, power);
  }
  return 0.5 * (pow(pos - 2., power) + 2.);
}

vec2 getCirclePoint(float id, float numCircleSegments, float snd) {
  id = mod(id, numCircleSegments * 6.);
  float ux = floor(id / 6.) + mod(id, 2.);
  float vy = mod(floor(id / 2.) + floor(id / 3.), 2.);

  float a = snd;//sin(time) * 0.5 + 0.5;
  float angle = ux / numCircleSegments * PI * mix(2., 12., a);
  float c = cos(angle);
  float s = sin(angle);

  float radius = mix(mix(0.75, 0.9, a), 1.0, vy) + ux * -0.004;
  float x = c * radius;
  float y = s * radius;

  return vec2(x, y);
}

void main() {
  float numCircleSegments = 200.0;
  float numPointsPerCircle = numCircleSegments * 6.;

  float circleId = floor(vertexId / numPointsPerCircle);
  float numCircles = floor(vertexCount / numPointsPerCircle);
  float circleV = circleId / numCircles;

  float sliceId = floor(vertexId / 6.);
  float oddSlice = 0.;//mod(sliceId, 2.);

  float segmentId = mod(sliceId, numCircleSegments);
  float segmentV = segmentId / numCircleSegments;
  float pointId = mod(vertexId, numPointsPerCircle);
  float pointV = pointId / numPointsPerCircle;
  float edgeId = floor(pointId / 6.) + mod(pointId, 2.);
  float edgeV = edgeId / (numPointsPerCircle / 6.);

  float down = sqrt(numCircles);
  float across = floor(numCircles / down);
  float x = mod(circleId, across);
  float y = floor(circleId / across);

  float u = x / (across - 1.);
  float v = y / (down - 1.);

  float su = abs(u - 0.5) * 2.;
  float sv = abs(v - 0.5) * 2.;

  float au = abs(atan(su, sv)) / PI;
  float av = length(vec2(su, sv));

  float snd = texture(sound, vec2(mix(0.01, 0.5, hash(circleV)), edgeV)).r;
  float sn2 = 0.;//texture(sound, vec2(au * 0.05, (1. - segmentV) * .9)).r;

  float xoff = 0.;//sin(time + y * 0.2) * 0.1;
  float yoff = 0.;//sin(time + x * 0.3) * 0.2;

  float ux = u * 2. - 1. + xoff;
  float vy = v * 2. - 1. + yoff;

  float sc = pow(snd + 0., 5.0) ;
  float aspect = resolution.x / resolution.y;

  vec2 circleXY = getCirclePoint(vertexId, numCircleSegments, mix(.05, 1., .2));

  float odd = mod(circleId, 2.);
  float dir = mix(-1., 1., odd);
  float st = time * .1 + circleV;
  float sz = floor(st);
  float sw = fract(st);
  float fd = sin(sw * PI);
  vec4 pos = vec4(circleXY, 0, 1);
  mat4 mat = ident();
  mat *= scale(vec3(1, aspect, 1));
  //mat *= rotZ(time * 0.1);
// mat *= trans(vec3(ux, vy, 0.) * 1.);
  mat *= trans(vec3(hash(circleId * 0.123 + sz), hash(circleId * 0.719 + sz), 0.) * 2. - 1.);
  float ss = .25 * snd;
  mat *= scale(vec3(ss, ss * dir, 1));
  mat *= rotZ(hash(circleV) * PI * 2. + time * 2.5);
  //mat *= rotZ(time * -10.);// + snd * 10. * sign(ux));

  gl_Position = mat * pos;
  gl_Position.z = -sin(sw);

  float soff = 1.;//sin(time + x * y * .02) * 5.;

  float pump = step(0.8, snd);
  float pmp2 = step(0.8, sn2);

  float hue = odd * 0.5 + .2;
  float sat = 0.;//mix(0.75, 1., pump);
  float val = 0.;//mix(.5, pow(snd + 0.2, 5.0), pump);

  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), 1);

  v_color.a = sin(sw * PI);

  v_color.rgb *= v_color.a;
}


// Removed built-in GLSL functions: transpose, inverse