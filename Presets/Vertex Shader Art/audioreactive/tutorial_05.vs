/*{
  "DESCRIPTION": "tutorial_05",
  "CREDIT": "kcha (ported from https://www.vertexshaderart.com/art/aY78NwrqSDZrC8tRW)",
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
    0.14901960784313725,
    0.3764705882352941,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 5,
    "ORIGINAL_DATE": {
      "$date": 1552793701983
    }
  }
}*/

vec3 hsv2rgb(vec3 c){
  c = vec3(c.x, clamp(c.yz, 0., 1.));
  vec4 K = vec4(1., 2. / 3., 1. / 3., 3.);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6. - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0., 1.), c.y);
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

vec2 getCirclePoint(float id, float numCircleSegments){
  // id = 0 1 2 3 4 5 6 7 8 9 10 11 12 13
  // 0 0 0 0 0 0 1 1 1 1 1 1 2 2
  // 0 1 0 1 0 1 0 1 0 1 0 1 0 1
  // 0 1 0 1 0 1 1 2 1 2 1 2 2 3
  float ux = floor(id / 6.) + mod(id, 2.);
  // id = 0 1 2 3 4 5 6 7 8 9 10 11 12 13
  // 0 0 1 1 2 2 3 3 4 4 5 5 6 6
  // 0 0 0 1 1 1 2 2 2 3 3 3 4 4
  // 0 0 1 0 1 1 1 1 0 1 0 0 0 0
  float vy = mod(floor(id / 2.) + floor(id / 3.), 2.);

  float angle = ux / numCircleSegments * PI * 2.;
  float c = cos(angle);
  float s = sin(angle);
  float radius = vy + 1.;

  float x = c * radius;
  float y = s * radius;

  return vec2(x, y);
}

void main(){
  float numCircleSegments = 12.;
  vec2 circleXY = getCirclePoint(vertexId, numCircleSegments);

  float numPointsPerCircle = numCircleSegments * 6.;
  float circleId = floor(vertexId / numPointsPerCircle);
  float numCircles = floor(vertexCount / numPointsPerCircle);

  float sliceId = floor(vertexId / 6.0);
  float oddSlice = mod(sliceId, 2.0);

  float down = floor(sqrt(numCircles));
  float across = floor(numCircles / down);

  float x = mod(circleId, across);
  float y = floor(circleId / across);

  // 0.0 - 1.0
  float u = x / (across - 1.); // .0, .1, ... , .9, .0, .1, ...
  float v = y / (across - 1.); // .0, .0, ... , .1, .1, ...

  float xoff = 0.;//sin(time + y * 0.2) * 0.1;
  float yoff = 0.;//sin(time + x * 0.3) * 0.2;

  float ux = u * 2. - 1. + xoff;
  float vy = v * 2. - 1. + yoff;

  // 0.0-1.0 => -0.5-0.5 => 0.5-0.0-0.5 => 1.0-0.0-1.0
  float su = abs(u - .5) * 2.;
  float sv = abs(v - .5) * 2.;
  float au = abs(atan(su, sv)) / PI;
  float av = length(vec2(su, sv));
  float snd = texture(sound, vec2(au * .05, av * .25)).r;

  float aspect = resolution.x / resolution.y;
  float sc = pow(snd + 0.2, 5.) * mix(1.0, 1.2, oddSlice);
  sc *= 20. / across;

  vec4 pos = vec4(circleXY, 0, 1);
  mat4 mat = ident();
  mat *= scale(vec3(1, aspect, 1));
  mat *= rotZ(time * 0.2);
  mat *= trans(vec3(ux, vy, 0) * 1.3);
  mat *= rotZ(snd * 15. * sign(ux));
  mat *= uniformScale(0.03 * sc);

  gl_Position = mat * pos;

  float soff = 0.; //sin(time + x * y * 0.02) * 5.;

  float pump = step(0.8, snd);
  float hue = u * .1 + snd * .2 + time * .2 + sliceId * 0.01;//sin(time + v * 20.) * .05;
  float sat = mix(0.8, 1.0, pump);//mix(1., 0., av);
  float val = mix(.4, pow(snd + .2, 5.), pump);//sin(time + v * u * 20.0) * .5 + .5;
  hue = hue + pump * oddSlice * 0.5 + pump * 0.33;
  val += oddSlice * pump;
  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), 1);
}
