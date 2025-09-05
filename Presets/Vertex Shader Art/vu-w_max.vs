/*{
  "DESCRIPTION": "vu-w/max",
  "CREDIT": "gman (ported from https://www.vertexshaderart.com/art/yKbsMohpXxZXWLHSm)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Geometry",
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 576,
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
    "ORIGINAL_VIEWS": 125,
    "ORIGINAL_DATE": {
      "$date": 1551122091060
    }
  }
}*/

/*

Just wanted to see if I could kind of make a VU meter with max levels
There's 3 parts to each column

1. The top: Max for last few moments. Currently 1/3 second (20 frames)
2. The red line: The instantaneous average for all frequenies in that column
3. The column itself: The instantaneous max

I'm a little surprised: It reads 20*64 (1280) per vertex. Setting it to 100k
still runs at 60fps on my NVidia GeForce GT 750M

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

float easeInOutPow(float pos, float pw) {
  if ((pos /= 0.5) < 1.) {
    return 0.5 * pow(pos, pw);
  }
  return 0.5 * (pow((pos - 2.), pw) + 2.);
}

void main() {
  float vId = mod(vertexId, 6.);
  float ux = floor(vId / 6.) + mod(vId, 2.);
  float vy = mod(floor(vId / 2.) + floor(vId / 3.), 2.);

  float quadsPerArea = 3.;
  float pointsPerArea = quadsPerArea * 6.;
  float areaId = floor(vertexId / pointsPerArea);
  float numAreas = floor(vertexCount / pointsPerArea);
  float areaV = areaId / numAreas;
  float areaVertId = mod(vertexId, pointsPerArea);
  float rowId = floor(areaVertId / 6.);

  float maxBarHeight = 0.025;
  const int numSamples = 20; // number of history samples to read. So 30 = 1/2 second
  const int samplesPerArea = 64; // samples across a row. There are 4096 samples I think
        // 128 would be 32 area

  float sampleRangePerArea = IMG_SIZE(sound).x / float(samplesPerArea);
  float sampleRangeMult = sampleRangePerArea / float(samplesPerArea) / IMG_SIZE(sound).x;

  float timeMaxS = 0.0;
  float instMaxS = 0.0;
  float avgS = 0.0;
  for (int j = 0; j < samplesPerArea; ++j) {
    float su = areaV + float(j) * sampleRangeMult;
    float s = texture(sound, vec2(su, 0)).r;
    avgS += s;
    instMaxS = max(s, instMaxS);
    timeMaxS = max(s, timeMaxS);
    for (int i = 1; i < numSamples; ++i) {
      s = texture(sound, vec2(su, (float(i) + .5) / IMG_SIZE(sound).y)).r;
      timeMaxS = max(s, timeMaxS);
    }
  }

  avgS /= float(samplesPerArea);

  float isRow2 = step(1.5, rowId);

  vec3 pos = vec3(ux, vy, rowId * -.1);
  mat4 mat = trans(vec3(-1, -1, 0));
  mat *= uniformScale(2.0);

  float row0 = 0.;
  float row1 = timeMaxS - maxBarHeight * .5;
  float row2 = avgS - maxBarHeight * .5;
  mat *= trans(vec3(
      0,
      mix(mix(row0, row1, step(0.5, rowId)), row2, isRow2),
      0));
  mat *= scale(vec3(1. / numAreas * .9, mix(instMaxS, maxBarHeight, step(0.5, rowId)), 1));
  mat *= trans(vec3(areaId * 1.1, 0, 0));

  gl_Position = mat * vec4(pos, 1);

  float hue = areaV * .2 + .6 + rowId * .9 + step(1.5, rowId) * .5;
  float sat = instMaxS;
  float val = mix(mix(0.2, 1.0, pow(instMaxS, 3.)), mix(0.2, 1.0, timeMaxS), rowId);
  val = mix(val, mix(0.4, 1.0, avgS), isRow2);
  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), 1);
}
// Removed built-in GLSL functions: transpose, inverse