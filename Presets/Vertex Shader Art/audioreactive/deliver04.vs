/*{
  "DESCRIPTION": "deliver04",
  "CREDIT": "p\u00f6stp\u00f6p (ported from https://www.vertexshaderart.com/art/S24QeFuvJgsKJ3gdB)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Geometry",
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 25000,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Background", "NAME": "background", "TYPE": "color", "DEFAULT": [ 0.25, 0.59, 0.9, 1.0 ] }, { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 1,
    "ORIGINAL_DATE": {
      "$date": 1540075906885
    }
  }
}*/

/*
        _
 _ _ ___ ___| |_ ___ _ _
| | | -_| _| _| -_|_'_|
 \_/|___|_| |_| |___|_,_|
     _ _
 ___| |_ ___ _| |___ ___
|_ -| | .'| . | -_| _|
|___|_|_|__,|___|___|_|
        _
 ___ ___| |_
| .'| _| _|
|__,|_| |_|

*/

#define PI radians(180.)

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

// hash function from https://www.shadertoy.com/view/4djSRW
float hash(float p) {
 vec2 p2 = fract(vec2(p * 5.3983, p * 5.4427));
    p2 += dot(p2.yx, p2.xy + vec2(21.5351, 14.3137));
 return fract(p2.x * p2.y * 95.4337);
}

mat4 rotX(float angle) {

    float s = sin( angle );
    float c = cos( angle );

    return mat4(
      1, 0, 0, 0,
      0, c, s, 0,
      0,-s, c, 0,
      0, 0, 0, 1);
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
  #if 0
  return mat4(
    1, 0, 0, trans[0],
    0, 1, 0, trans[1],
    0, 0, 1, trans[2],
    0, 0, 0, 1);
  #else
  return mat4(
    1, 0, 0, 0,
    0, 1, 0, 0,
    0, 0, 1, 0,
    trans, 1);
  #endif
}

mat4 ident() {
  return mat4(
    1, 0, 0, 0,
    0, 1, 0, 0,
    0, 0, 1, 0,
    0, 0, 0, 1);
}

mat4 uniformScale(float s) {
  return mat4(
    s, 0, 0, 0,
    0, s, 0, 0,
    0, 0, s, 0,
    0, 0, 0, 1);
}

mat4 scale(vec3 s) {
  return mat4(
    s[0], 0, 0, 0,
    0, s[1], 0, 0,
    0, 0, s[2], 0,
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

float m1p1(float v) {
  return v * 2. - 1.;
}

float p1m1(float v) {
  return v * .5 + .5;
}

float inRange(float v, float minV, float maxV) {
  return step(minV, v) * step(v, maxV);
}

float at(float v, float target) {
  return inRange(v, target - 0.1, target + 0.1);
}

vec3 getRandomCubePoint(float seed) {
  vec3 p = vec3(
    m1p1(hash(seed)),
    m1p1(hash(seed * 0.731)),
    m1p1(hash(seed * 1.319)));
  float axis = hash(seed * 0.911) * 3.;
  if (axis < 1.) {
    p[0] = mix(-1., 1., step(0., p[0]));
  } else if (axis < 2.) {
    p[1] = mix(-1., 1., step(0., p[1]));
  } else {
    p[2] = mix(-1., 1., step(0., p[2]));
  }
  return p;
}

vec3 getRandomBoxPoint(float seed) {
  vec3 p = vec3(
    m1p1(hash(seed)),
    m1p1(hash(seed * 0.731)),
    m1p1(hash(seed * 1.319)));
  float axis = hash(seed * 0.911) * 3.;
  if (axis < 1.) {
    p[0] = mix(-1., 1., step(0., p[0]));
    p[1] = mix(-1., 1., step(0., p[1]));
  } else if (axis < 2.) {
    p[1] = mix(-1., 1., step(0., p[1]));
    p[2] = mix(-1., 1., step(0., p[2]));
  } else {
    p[2] = mix(-1., 1., step(0., p[2]));
    p[0] = mix(-1., 1., step(0., p[0]));
  }
  return p;
}

vec3 getRandomSpherePoint(float seed) {
  return normalize(vec3(
    m1p1(hash(seed)),
    m1p1(hash(seed * 0.731)),
    m1p1(hash(seed * 1.319))));
}

vec3 getRandomSphereVolumePoint(float seed) {
  return normalize(vec3(
    m1p1(hash(seed)),
    m1p1(hash(seed * 0.731)),
    m1p1(hash(seed * 1.319)))) * hash(seed * 2.117);
}

vec3 getRandomCubeVolumePoint(float seed) {
  return vec3(
    m1p1(hash(seed)),
    m1p1(hash(seed * 0.731)),
    m1p1(hash(seed * 1.319)));
}

vec3 getRandomFunkPoint(float seed, float xDivs, float yDivs) {
  mat4 m = rotX(PI * 2.0 * floor(hash(seed) * xDivs) / xDivs);
  m *= rotY(PI * 2.0 * floor(hash(seed * 0.731) * yDivs) / yDivs);
  m *= rotZ(hash(seed * 0.311) * PI * 2.);
  return (m * vec4(vec2(hash(seed * 2.117), 0) * 0.5, 1, 1)).xyz;
}

vec3 getRandomFunkOutPoint(float seed, float xDivs, float yDivs) {
  mat4 m = rotX(PI * 2.0 * floor(hash(seed) * xDivs) / xDivs);
  m *= rotY(PI * 2.0 * floor(hash(seed * 0.731) * yDivs) / yDivs);
  m *= rotZ(hash(seed * 0.311) * PI * 2.);
  return (m * vec4(vec2(1, 0) * 0.5, 1, 1)).xyz;
}

vec3 getPoint(float set, float seed) {
  set = mod(set, 7.);
  if (set < 1.)
  {
    return getRandomCubePoint(seed);
  }
  if (set < 2.)
  {
    return getRandomSphereVolumePoint(seed);
  }
  if (set < 3.)
  {
    return getRandomFunkPoint(seed, 3., 3.);
  }
  if (set < 4.)
  {
    return getRandomSpherePoint(seed);
  }
  if (set < 5.)
  {
    return getRandomBoxPoint(seed);
  }
  if (set < 6.)
  {
    return getRandomCubeVolumePoint(seed);
  }
  return getRandomFunkOutPoint(seed, 4., 3.);
}

float easeInOutCubic(float pos) {
  if ((pos /= 0.5) < 1.) {
    return 0.5 * pow(pos, 3.);
  }
  return 0.5 * (pow((pos - 2.), 3.) + 2.);
}

vec3 getLerpedPoint(float time, float seed) {
  float set = mod(time, 7.);
  vec3 p0 = getPoint(set, seed);
  vec3 p1 = getPoint(set + 1., seed);
  return mix(p0, p1, easeInOutCubic(fract(time)));
}

#define DOTS_PER 4000.

void main() {
  float v = vertexId / vertexCount;
  float invV = 1.0 - v;
  float thingId = floor(vertexId / DOTS_PER);
  float numThings = floor(vertexCount / DOTS_PER);
  float thingV = thingId / numThings;

// float snd = texture(sound, vec2(thingV * 0.05 + 0.01, mod(time + thingV * 4., 4.) * 60. / 240.)).r;
  float snd = texture(sound, vec2(thingV * 0.05 + 0.01, 0.)).r;
  vec3 p = getLerpedPoint(time + thingV + hash(thingId) * 7., v * 4. + time * 0.01);
// vec3 p = getLerpedPoint(snd * 6., v * 4. + time * 0.01);

  float cameraRadius = 13.;
  float camAngle = time * 0.3;
  vec3 eye = vec3(cos(camAngle) * cameraRadius, sin(time) * 3., sin(camAngle) * cameraRadius);
  vec3 target = vec3(0, 0, 0);
  vec3 up = vec3(0, 1, 0);

  mat4 m = persp(radians(60.), resolution.x / resolution.y, 1., 29.);
  m *= cameraLookAt(eye, target, up);
  m *= trans(vec3(
    m1p1(hash(thingId * 0.179)) * 6.,
    m1p1(hash(thingId * 0.317)) * 6.,
    m1p1(hash(thingId * 0.251)) * 6.));
  m *= uniformScale(mix(1.0, 1.5, hash(thingId * 0.799)));
  gl_Position = m * vec4(p, 1);
  float clipZ = p1m1(gl_Position.z / gl_Position.w);
  float invClipZ = 1. - clipZ;

  float hue = 0.8+ v * 0.1;
  hue = mix(hue, 0.5, mod(floor(time * 60.0), 2.));
  hue = mix(hue, .3, step(0.9, snd));
  float sat = 1.;
  float val = invClipZ * 150.;
  v_color = vec4(mix(background.rgb, hsv2rgb(vec3(hue, sat, val)), pow(snd, 3.0)), 1);
  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), mix(0., 2.5, pow(snd, 4.0)));
  v_color = vec4(v_color.rgb * v_color.a, v_color.a);
  gl_PointSize = 18. / gl_Position.z;
}
// Removed built-in GLSL functions: transpose, inverse