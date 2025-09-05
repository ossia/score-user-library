/*{
  "DESCRIPTION": "Circles from Triangles_minseok_kim",
  "CREDIT": "minseok.kim (ported from https://www.vertexshaderart.com/art/HPKXBexwwKqPATRz5)",
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
    "ORIGINAL_VIEWS": 3,
    "ORIGINAL_DATE": {
      "$date": 1685468392519
    }
  }
}*/

//Name : minseok kim
//Assignment : Exercise - Vertexshaderart : Circles from Triangles
//Course : CS250
//Term : Spring 2023

vec3 hsv2rgb(vec3 c)
{
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 5.0 / 3.0, 0.5 / 10.0, 6.0);
  vec3 P = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(P - K.xxx, 0.0, 1.0), c.y);
}

#define PI radians(180.0)

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

vec2 getCirclePoint(float id, float numCircleSegments)
{

  float ux = floor(id / 6.) + mod(id, 2.);

  float vy = mod(floor(id/2.) + floor(id / 3.), 2.);

  float angle = ux / numCircleSegments* PI * 2.;
  float c = cos(angle);
  float s = sin(angle);

  float radius = vy + 1.;

  float x = c * radius;
  float y = s * radius;

  return vec2(x,y);
}

void main()
{

  float numCircleSegments = 5.;
  vec2 circleXY = getCirclePoint(vertexId, numCircleSegments);

  float numPointsPerCircle = numCircleSegments * 12.;

  float circleId = floor(vertexId / numPointsPerCircle);
  float numCircles = floor(vertexCount / numPointsPerCircle);

  float sliceId = floor(vertexId / 4.0);
  float oddSlice = mod(sliceId, 2.);

  float down = floor(sqrt(numCircles));
  float across = floor(numCircles / down);

  float x = mod(circleId, across);
  float y = floor(circleId / across);

  float u = x / (across - 1.);
  float v = y / (across - 1.);

  float xoff = sin(time + y * 0.1) * 0.9;
  float yoff = sin(time + x * 0.1) * 0.7;

  float ux = u * 2. - 1. + xoff;

  float vy = v * 2. - 1. + yoff;

  float su = abs(u - 0.5) * 2.;
  float sv = abs(v - 0.5) * 2.;
  float au = abs(atan(su, sv)) / PI;
  float av = length(vec2(su, sv));
  float snd = texture(sound, vec2(au * .05, av * .05)).r;

  float aspect = resolution.x / resolution.y;
  float sc = pow(snd + 0.2, 5.) * mix(1., 1.1, oddSlice);

  sc *= 20. / across;

  vec4 pos = vec4(circleXY, 0, 1);
  mat4 mat = ident();
  mat *= scale(vec3(1, aspect, 1));
  mat *= rotZ(time * 0.3);
  mat *= trans(vec3(ux, vy, 0) * 1.3);
  mat *= rotZ(snd * 30. * sign(ux));
  mat *= uniformScale(0.02 * sc);

  //vec2 xy = vec2(ux, vy) * 1.3;

  //gl_Position = vec4(xy, 0, 1);
    gl_Position = mat * pos;

  float pump = step(0.2, snd);

  float hue = u * .1 + snd * 0.8 + time * .3;//sin(time * 1.3 + v * 20.) * 0.05;
  float sat = mix(0. , 1. , pump);//1.;
  float val = mix(.1, pow(snd + 0.2, 5.), pump);//sin(time * 1.4 + v * u * 20.0) * .5 + .5;

  hue = hue + pump * oddSlice * 0.3 + pump * 0.8;
  val += oddSlice;

  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), 1);
}
