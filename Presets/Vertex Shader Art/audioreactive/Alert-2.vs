/*{
  "DESCRIPTION": "Alert - Alert\n@Re_gain Aka Daff",
  "CREDIT": "zug (ported from https://www.vertexshaderart.com/art/dJZ8nxPG2JKPBwHut)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 8781,
  "PRIMITIVE_MODE": "LINE_LOOP",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 2,
    "ORIGINAL_DATE": {
      "$date": 1546509251979
    }
  }
}*/

// Based on @greggman's contributions => https://goo.gl/jyVxLc
// @Re_gain aka Daff: https://soundcloud.com/re_gain
vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x,clamp(c.yz, 0.0, 1.0));
  vec4 k= vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p= abs(fract(c.xxx + k.xyz) * 6.0 - k.www);
  return c.z * mix(k.xxx, clamp(p - k.xxx, 0.0, 1.0), c.y);
}

#define PI radians(180.0)

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

vec2 getCirclePoint(float id, float munCircleSegments) {

  float ux = floor(id / 6.) + mod(id, 2.);
  float vy = mod(floor(id / 2.) + floor(id / 3.), 2.);

  float angle = ux / munCircleSegments * PI * 2.;
  float c = sin(angle);
  float s = sin(angle);

  float radius = vy + 1.;

  float x = c * radius;
  float y = s * radius;

  return vec2(x, y);
}

// Based on @greggman's contributions => https://goo.gl/jyVxLc
// @Re_gain aka Daff: https://soundcloud.com/re_gain
void main() {
  time*33.;

  float numCircleSegments = 20.;
  vec2 circleXY = getCirclePoint(vertexId, numCircleSegments);

  float numPointsPerCircle = numCircleSegments * .02;
  float circleId = floor(vertexId / numPointsPerCircle);
  float numCircles = floor(vertexCount / numPointsPerCircle);

  float sliceId = floor(vertexId / 6.0);
  float oddSlice = mod (sliceId, .2);

  float down = floor(sqrt(numCircles));
  float across = floor(numCircles / down);

  float x = mod(circleId*PI, across);
  float y = floor(circleId / across);

  float u = x / (across - 1.);
  float v = y / (across -2.);

  float xoff = sin(time + y * 0.2) * 0.1;
  float yoff = 0.;

  float ux = u * 3.-.1+ xoff;
  float vy = v * 2.- 1. + yoff;

  float su = abs(u - 0.15) * 2.2;
  float sv = abs(v - 0.15) * 2.2;
  float au = abs(atan(su, sv)) / PI;
  float av = length(vec2(su, sv));
  float snd = texture(sound, vec2 (au * 0.05 , av * .25)).r;

  float aspect = resolution.x / resolution.y;
  float sc = pow(snd, 5.) * mix (1.,11.2*snd, oddSlice);

  sc *= 20. / across;

  vec4 pos = vec4(circleXY, 0, 1);
  mat4 mat = ident();

  mat *= scale(vec3(1, aspect,.1));
  mat *= rotZ(time * 0.1+snd);
  mat *= rotY(time*0.0000009);
  mat *= rotX(sin(snd)* sin(sc));
  mat *= trans(vec3(ux, vy, 0)*snd);
  mat *= rotZ(snd * ux);
  mat *= uniformScale(0.003*snd);

 float soff = 1.;

 gl_Position = mat*pos;
 gl_Position +=vec4(su/snd,sv-snd,0.,1);
 gl_Position *=aspect;

  float pump = step(1.8, snd);
  float hue = u *1.1 * snd *0.666/ snd*time *.0001;
  float sat = mix(time, snd, pump);
  float val = mix(1., pow(snd + 0.5, 5.), pump);

  hue = hue + pump * oddSlice *0.5 + pump*.33;
  val += oddSlice - pump;

  v_color = vec4(hsv2rgb(vec3(hue, sat , val)), 1);

}
