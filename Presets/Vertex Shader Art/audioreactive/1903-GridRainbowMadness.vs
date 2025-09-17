/*{
  "DESCRIPTION": "1903-GridRainbowMadness",
  "CREDIT": "janalex (ported from https://www.vertexshaderart.com/art/uPZQYGHJDM4trFXcC)",
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
    "ORIGINAL_VIEWS": 349,
    "ORIGINAL_LIKES": 1,
    "ORIGINAL_DATE": {
      "$date": 1553348336337
    }
  }
}*/


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

#define PI radians(180.0)

vec2 getCirclePoint(float id, float sumCircleSegments) {
  float ux = floor(id / 6.0) + mod(id, 2.0);
  float vy = mod(floor(id / 2.0) + floor(id / 3.0), 2.0);
  // create a horizontal triangle strip

  float angle = ux / sumCircleSegments * PI * 2.0;
  float c = cos(angle);
  float s = sin(angle);

  float radius = vy + 1.0;

  float x = c * radius;
  float y = s * radius;

  return vec2(x, y);
}

void main() {
  float sumCircleSegments = 12.0;
  vec2 circleXY = getCirclePoint(vertexId, sumCircleSegments);

  float numPointsPerCircle = sumCircleSegments * 6.0;
  float circleId = floor(vertexId / numPointsPerCircle);
  float numCircles = floor(vertexCount / numPointsPerCircle);

  float sliceId = floor(vertexId / 6.0);
  float oddSlice = mod(sliceId, 2.0);

  float down = floor(sqrt(numCircles));
  float across = floor(numCircles / down);

  float x = mod(circleId, across);
  float y = floor(circleId / across);

  float u = x / (across - 1.0);
  float v = y / (across - 1.0);

  float xoff = 0.0; // sin(time + y * 0.2) * 0.01;
  float yoff = 0.0; //sin(time * 1.1 + x * 0.3) * 0.02;

  float ux = u * 2.0 - 1.0 + xoff;
  float vy = v * 2.0 - 1.0 + yoff;

  float su = abs(u - 0.5) * 1.0;
  float sv = abs(v - 0.5) * 2.0;
  float au = abs(atan(su, sv)) / PI;
  float av = length(vec2(su, sv));
  float snd = texture(sound, vec2(au * 0.05, av * 0.25)).z;

  float aspect = resolution.x / resolution.y;
  float sc = pow(snd + 0.2, 4.0) / 9.0 + mix(1.0, 1.1, oddSlice) * 0.01;

  sc *= 15.0 / across;

  vec4 pos = vec4(circleXY, 0.0, 1.0);
  mat4 mat = ident();
  mat *= scale(vec3(1.0, aspect, 1.0));
  mat *= rotZ(time * 0.05);
  mat *= trans(vec3(ux, vy, 0.0) * 2.0);
  mat *= rotZ(snd * 2.0 * sign(ux));
  mat *= uniformScale(0.5 * sc);

  gl_Position = mat * pos;

  float soff = snd; // sin(time * 1.2 + x * y * 0.02) * 5.0;

  gl_PointSize = pow(snd + 0.3, 5.0) * 10.0 + soff;
  gl_PointSize *= 20.0 / across;
  gl_PointSize *= resolution.x / 600.0;

  float pump = step(0.8, snd);
  float hue = u * 0.1 + snd + sin(time * 0.1) + 0.0 * sliceId * 0.01; // sin(time * 1.2 + v * 5.0) * 0.1;
  float sat = 1.0;mix(0.0, 1.0, pump);
  float val = 1.0; mix(0.1, pow(snd + 0.2, 5.0), pump); //sin(time * 1. + v * u * 20.0) + 0.5;

  hue = hue + pump * oddSlice * 0.8 + pump * 0.33;
  val += oddSlice + pump;

  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), 1.0);
}