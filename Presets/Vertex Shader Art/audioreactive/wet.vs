/*{
  "DESCRIPTION": "wet",
  "CREDIT": "gman (ported from https://www.vertexshaderart.com/art/cZoyrQ8kQECXDtSTn)",
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
    0.9176470588235294,
    1,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 330,
    "ORIGINAL_LIKES": 8,
    "ORIGINAL_DATE": {
      "$date": 1448448172039
    }
  }
}*/

/*

        /) /)
_ _ _ __ _/_ _ __/ _ (/ _ _(/ _ __ _ __ _/_
(/___(/_/ (_(___(/_ /(__/_)_/ )_(_(_(_(__(/_/ (_(_(_/ (_(__
        /

*/

#define PI radians(180.0)

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
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

// hash function from https://www.shadertoy.com/view/4djSRW
float hash(float p) {
 vec2 p2 = fract(vec2(p * 5.3983, p * 5.4427));
    p2 += dot(p2.yx, p2.xy + vec2(21.5351, 14.3137));
 return fract(p2.x * p2.y * 95.4337);
}

float m1p1(float v) {
  return v * 2. - 1.;
}

float p1m1(float v) {
  return v * 0.5 + 0.5;
}

float inv(float v) {
  return 1. - v;
}

#define NUM_EDGE_POINTS_PER_CIRCLE 48.
#define NUM_POINTS_PER_CIRCLE (NUM_EDGE_POINTS_PER_CIRCLE * 6.)
void getCirclePoint(const float id, const float inner, const float start, const float end, out vec3 pos) {
  float outId = id - floor(id / 3.) * 2. - 1.; // 0 1 2 3 4 5 6 7 8 .. 0 1 2, 1 2 3, 2 3 4
  float ux = floor(id / 6.) + mod(id, 2.);
  float vy = mod(floor(id / 2.) + floor(id / 3.), 2.); // change that 3. for cool fx
  float u = ux / NUM_EDGE_POINTS_PER_CIRCLE;
  float v = mix(inner, 1., vy);
  float a = mix(start, end, u) * PI * 2. + PI * 0.0;
  float s = sin(a);
  float c = cos(a);
  float x = c * v;
  float y = s * v;
  float z = 0.;
  pos = vec3(x, y, z);
}

float goop(float t) {
  return sin(t) + sin(t * 0.27) + sin(t * 0.13) + sin(t * 0.73);
}

void main() {
  float circleId = floor(vertexId / NUM_POINTS_PER_CIRCLE);
  float pointId = mod(vertexId, NUM_POINTS_PER_CIRCLE);
  float sideId = floor(circleId / 2.);
  float side = mix(-1., 1., step(0.5, mod(circleId, 2.)));
  float numCircles = floor(vertexCount / NUM_POINTS_PER_CIRCLE);
  float cu = circleId / numCircles;
  vec3 pos;
  float inner = mix(0.2, 0.8, p1m1(sin(goop(sideId) + time)));
  float start = fract(hash(sideId * 0.33) + 0. * fract(time + sideId) * 1.1);
  float end = start + hash(sideId + 1.);
  getCirclePoint(pointId, inner, start, end, pos);

  vec3 offset = vec3(hash(sideId) * 0.8, m1p1(hash(sideId * 0.37)), 0);
  offset.x += goop(sideId + time) * 0.1;
  offset.y += goop(sideId + time * 1.13) * 0.1;
  offset.z = m1p1(cu);
  vec3 aspect = vec3(side, resolution.x / resolution.y, 1.);

  #define AVERAGE 5
  float snd = 0.;
  for (int i = 0; i < AVERAGE; ++i) {
    snd += texture(sound, vec2(0.02 + cu * 0.2, (pointId + float(i)) / NUM_POINTS_PER_CIRCLE * 0.5)).r * float(AVERAGE - i);
  }
  snd /= float(AVERAGE * (AVERAGE + 1)) * 0.5;

  mat4 mat = ident();
  mat *= scale(aspect);
  mat *= trans(offset);
  mat *= uniformScale(mix(0.0, 0.1, hash(sideId)) * 0.0 + pow(snd, 1.0) * 0.3);
  gl_Position = vec4((mat * vec4(pos, 1)).xyz, 1);
  gl_PointSize = 4.;

  float hue = mix(0.5, 0.55, fract(sideId * 0.79));
  float sat = mix(0.3 + snd, 0., step(0.9, snd));
  float val = 1.;
  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), 1.0);
  v_color = vec4(v_color.rgb * v_color.a, v_color.a);
}