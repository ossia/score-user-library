/*{
  "DESCRIPTION": "grid attempt",
  "CREDIT": "evilprofesseur (ported from https://www.vertexshaderart.com/art/4e4L6TCCcTrTkKJbh)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 62000,
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
    "ORIGINAL_VIEWS": 12,
    "ORIGINAL_DATE": {
      "$date": 1472807609813
    }
  }
}*/

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

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

#define PI radians(180.0)

vec2 getCirclePoint(float id, float circleSegmentsCount) {
  float ux = floor(id /6.) + mod(id, 2.);

  float vy = mod(floor(id /2.) + floor(id /3.), 2.);

  float angle = ux / circleSegmentsCount * PI * 2.;
  float c = cos(angle);
  float s = sin(angle);

  float radius = vy + 1.;

  float x = c * radius;
  float y = s * radius;

  return vec2(x,y);
}

void main() {
  float circleSegmentsCount = 6.;
  vec2 circleXY = getCirclePoint(vertexId, circleSegmentsCount);

  float pointsPerCircle = circleSegmentsCount * 6.;
  float circleId = floor(vertexId / pointsPerCircle);
  float circleCount = floor(vertexCount/ pointsPerCircle);

  float down = sqrt(circleCount);
  float across = floor(circleCount / down);

  float x = mod(circleId, across);
  float y = floor(circleId / across);

  float u = x / (across - 1.);
  float v = y / (across - 1.);

  float xOffset = 0.; //sin(time*2.1 + y * 0.2) * 0.1;
  float yOffset = 0.; //sin(time + x * 0.3) * 0.2;

  float ux = u * 2. - 1. + xOffset; // switch from 0-1 to -1-1
  float vy = v * 2. - 1. + yOffset;

  float su = abs(u- 0.5) * 2.;
  float sv = abs(v - 0.5) * 2.;
  float au = abs(atan(su, sv)) / PI;
  float av = length(vec2(su, sv));
  float snd = texture(sound, vec2(au* 0.125, av * 0.25)).r;

  float aspect = resolution.x / resolution.y;
  float sc = pow(snd + 0.2, 5.);

  vec4 pos = vec4(circleXY, 0 ,1);
  mat4 mat = ident();
  mat *= scale(vec3(1, aspect, 1));
  mat *= trans(vec3(ux, vy, 0));
  mat *= rotZ(snd * 10.);
  mat *= uniformScale(0.03 * sc);

  vec2 xy = circleXY * 0.02 * sc + vec2(ux, vy) *1.3;

  gl_Position = mat * pos;

  float sizeOffset = sin(time*0.7 + x * y * 0.02) * 5. + snd*15.;

  gl_PointSize = pow(snd + 0.3, 5.) * 10.0 + sizeOffset;
  gl_PointSize *= 20.0 / across;
  gl_PointSize *= resolution.x / 600.0;

  float hue = u * .1 + snd *0.3 + time * 0.1;
  float sat = smoothstep(0.1, 1.0, av);
  float val = pow(snd + 0.2 , 4.);

  v_color = vec4(hsv2rgb(vec3(hue,sat,val)),1);
}