/*{
  "DESCRIPTION": "Circles from Triangles 2",
  "CREDIT": "seoseulbin (ported from https://www.vertexshaderart.com/art/edJC7G3Sd2mixhfmg)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 5403,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.023529411764705882,
    0.06666666666666667,
    0.11764705882352941,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 3,
    "ORIGINAL_DATE": {
      "$date": 1685534496594
    }
  }
}*/

// Seulbin Seo
// Exercise Circles from Triangles 2
// CS250 Spring 2023

vec3 hav2rgb(vec3 c)
{
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.x * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

#define PI radians(180.)

mat4 rotZ(float angleInRadians)
{
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

vec2 getCirclePoint(float id, float numCircleSegments)
{
  float ux = floor(id / 6.) + mod(id, 2.);
  float vy = mod(floor(id / 2.) + floor(id / 3.), 2.);

  float angle = ux / numCircleSegments * PI * 2.0;
  float c = cos(angle);
  float s = sin(angle);

  float radius = vy + 1.;

  float x = c * radius * cos(time) / 2.;
  float y = s * radius * sin(time);

 return vec2(x,y);
}

void main ()
{
  float numCircleSegments = 6.;
  vec2 circleXY = getCirclePoint(vertexId, numCircleSegments);

  float numPointPerCircle = numCircleSegments * 6.;
  float circleId = floor(vertexId / numPointPerCircle);
  float numCircles = floor(vertexCount / numPointPerCircle);

  float sliceId = floor(vertexId / 6.0);
  float oddSlice = mod(sliceId, 2.);

  float down = floor(sqrt(numCircles));
  float across = floor(numCircles / down);

  float x = mod(circleId, across);
  float y = floor(circleId / across);

  float u = x / (across - 1.);
  float v = y / (across - 1.);

  float xoff = 0.; //sin(time + y * 0.2) * 0.1;
  float yoff = 0.; //sin(time + x * 0.3) * 0.2;

  float ux = u * 2. - 1. + xoff;
  float vy = v * 2. - 1. + yoff;

  float su = abs(u - 0.5) * 2.;
  float sv = abs(v - 0.5) * 2.;
  float au = abs(atan(su, sv)) / PI;
  float av = length(vec2(sv, su));
  float snd = texture(sound, vec2(au * .05, av * .25)).r;

  float aspect = resolution.x / resolution.y;
  float sc = pow(snd + 0.2, 5.) *mix(1., 1.1, oddSlice);

  sc *= 37. * cos(time) / across ;

  vec4 pos = vec4(circleXY, 0, 1);
  mat4 mat = ident();
  mat *= scale(vec3(1, aspect, 1));
  mat *= rotZ(time * sin(0.7));
  mat *= trans(vec3(ux, vy, 0) * 1.4);
  mat *= rotZ(snd * 10. * sign(vy));
  mat *= uniformScale(0.04 * sc);

  gl_Position = mat * pos;

  float soff = 0.; //sin(time * 1.2 + x * y * 0.02) * 5.;

  float pump = step(0.4, snd);
  float hue = u * .1 + snd * 0.2 + time * .1; // + sin(time * 1.3 + v * 20.) * 0.05;
  float sat = 1.;//mix(0.5, 1., pump);
  float val = mix(.4, pow(snd + 0.2, 5.), pump); //sin(time * 1.4 + v * u * 20.0) * .5 + .5;

 hue = hue + pump * oddSlice * 0.5 + pump * 0.33;
  val += oddSlice * pump;

  v_color = vec4 (hav2rgb(vec3(hue, sat, val)), 1);
}