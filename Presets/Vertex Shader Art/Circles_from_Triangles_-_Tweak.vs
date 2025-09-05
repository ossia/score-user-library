/*{
  "DESCRIPTION": "Circles from Triangles - Tweak",
  "CREDIT": "joonho.hwang (ported from https://www.vertexshaderart.com/art/cxEbTRudczrikaEBX)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math"
  ],
  "POINT_COUNT": 59737,
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
    "ORIGINAL_VIEWS": 4,
    "ORIGINAL_DATE": {
      "$date": 1685264476149
    }
  }
}*/

// Joonho Hwang
// Exercise Circles from Triangles
// CS250 Spring 2022

/// These helper functions are from https://www.vertexshaderart.com/art/qjkP6BDvEFyD6CfZC
#define PI radians(180.)

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
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
///

vec2 getCirclePoint(float id, float circleSegmentCount)
{
  float ux = floor(id / 6.0) + mod(id, 2.0);
  float vy = mod(floor(id / 2.0) + floor(id / 3.0), 2.0);

  float angle = ux / circleSegmentCount * PI * 2.0;
  float c = cos(angle);
  float s = sin(angle);

  float radius = vy + 1.0;
  return vec2(c, s) * radius;
}

void main()
{
  float circleSegmentCount = 12.0;
  vec2 circleXY = getCirclePoint(vertexId, circleSegmentCount);

  float pointCountPerCircle = circleSegmentCount * 6.0;
  float circleId = floor(vertexId / pointCountPerCircle);
  float circleCount = floor(vertexCount / pointCountPerCircle);

  float sliceId = floor(vertexId / 6.0);
  float oddSlice = mod(sliceId, 2.0);

  float down = floor(sqrt(circleCount));
  float across = floor(circleCount / down);

  float x = mod(circleId, across);
  float y = floor(circleId / across);

  float u = x / (across - 1.0);
  float v = y / (across - 1.0);

  float xOffset = 0.0;
  float yOffset = 0.0;

  float ux = u * 2.0 - 1.0 + xOffset;
  float vy = v * 2.0 - 1.0 + yOffset;

  float su = abs(u - 0.5) * 2.0;
  float sv = abs(v - 0.5) * 2.0;
  float au = abs(atan(su, sv)) / PI;
  float av = length(vec2(su, sv));
  float snd = texture(sound, vec2(au * 0.05, av * 0.25)).r;

  float aspect = resolution.x / resolution.y;
  float sc = pow(snd + 0.1, 7.0) * mix(1.0, 1.1, oddSlice);
  sc *= 20.0 / across;

  vec4 pos = vec4(circleXY, 0.0, 1.0);
  mat4 mat = ident();
  mat *= scale(vec3(1, aspect, 1));
  mat *= rotZ(texture(sound, vec2(au * 0.0001, av * 0.1)).r * -2.5);
  mat *= trans(vec3(ux,vy, 0) * 1.4);
  mat *= rotZ(snd * 20.0 * sign(ux));
  mat *= uniformScale(0.03 * sc);
  gl_Position = mat * pos;

  const float range = 120.0;
  const float block = 120.0 / 240.0;
  float sum = 0.0;
  for (float b = 0.0; b < range / 240.0; b += block)
  {
    sum += texture(sound, vec2(b, av * 0.25)).r;
  }

  float pump = step(0.8, snd);
  float hue = sum / block;
  float saturation = 1.0;
  float value = mix(0.4, pow(snd + 0.2, 5.0), pump);

  hue += pump * oddSlice * 0.1;
  value += oddSlice * pump;

  v_color = vec4(hsv2rgb(vec3(hue, saturation, value)), 1);
}