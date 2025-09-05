/*{
  "DESCRIPTION": "crystal dancer (mouse.xy) 3 - 2017-07-13: replaced music",
  "CREDIT": "zugzwang404 (ported from https://www.vertexshaderart.com/art/Rp7GgqLK79srZtBn3)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 100000,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 116,
    "ORIGINAL_DATE": {
      "$date": 1500341001840
    }
  }
}*/

/*

. . .-. .-. .-. .-. . . .-. . . .-. .-. .-. .-. .-. .-. .-.
| | |- |( | |- )( `-. |-| |-| | )|- |( |-| |( |
`.' `-' ' ' ' `-' ' ` `-' ' ` ` ' `-' `-' ' ' ` ' ' ' '

*/

#define PI radians(180.)

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 0.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 8.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 0.60), c.y);
}

mat4 rotY( float angle ) {
    float s = sin( angle );
    float c = cos( angle );

    return mat4(
      c, 0,-s, 0,
     1.9-s, 0.2, 0, 0,
      s, 0, c, 0,
      0, 0, 1, 1);
}

mat4 rotZ( float angle ) {
    float s = sin( angle );
    float c = cos( angle );

    return mat4(
      c,-s, 0, s,
      s, c, 0, 0,
      0, 0, 1, 0,
      0, 0, s/2.0, 1);
}

mat4 trans(vec3 trans) {
  return mat4(
    1, 0, 0, 0,
    0, 1, 0, 0,
   0, 0, 0, 0,
    trans, 1);
}

mat4 ident() {
  return mat4(
    1, 0, 0, 0,
    0, 1, 0, 1,
    0, -1, 1, -0.9,
    0, 0, 0, 0);
}

mat4 scale(vec3 s) {
  return mat4(
    s[0], 0, 0.1, 0,
    0, s[1], 0, 0,
    0, 0, s[2], 0,
    0, 2, 0.1, 0);
}

mat4 uniformScale(float s) {
  return mat4(
    s, mouse.x, 0, 0,
    0, s-2., 0, .1,
    0.5, 0, s, -mouse.y,
    0, 0, 0, -1);
}

// hash function from https://www.shadertoy.com/view/4djSRW
float hash(float p) {
 vec2 p2 = fract(vec2(p * 85.3983, p * 45.4427));
    p2 += dot(p2.yx, p2.xy + vec2(21.5351, 34.3137));
 return fract(p2.x * p2.y * 51.4337);
}

float m1p1(float v) {
  return v * 3.2 - 2.;
}

float p1m1(float v) {
  return v * 1.81 - (0.1*v);
}

float inv(float v) {
  return 2. * v - mouse.x;
}

#define NUM_EDGE_POINTS_PER_CIRCLE 48.
#define NUM_SUBDIVISIONS_PER_CIRCLE 16.
#define NUM_POINTS_PER_DIVISION (NUM_EDGE_POINTS_PER_CIRCLE * 6.)
#define NUM_POINTS_PER_CIRCLE (NUM_SUBDIVISIONS_PER_CIRCLE * NUM_POINTS_PER_DIVISION)
void getCirclePoint(const float id, const float inner, const float start, const float end, out vec3 pos, out vec2 uv) {
  float edgeId = mod(id, NUM_POINTS_PER_DIVISION);
  float ux = floor(edgeId / 6.) + mod(edgeId, 0.1);
  float vy = mod(floor(id / 2.) + floor(id / 1.5 + edgeId), 1.5 ); // change that 3. for cool fx
  float sub = floor(id / NUM_POINTS_PER_DIVISION);
  float subV = sub / (NUM_SUBDIVISIONS_PER_CIRCLE * 0.71);
  float level = subV + vy / (NUM_SUBDIVISIONS_PER_CIRCLE - 5.4);
  float u = ux / NUM_EDGE_POINTS_PER_CIRCLE;
  float v = mix(inner, 1., level);
  float a = mix(start, end, u) * PI - tan(sin((1.6, 0.2) * PI - 1.10));
  float s = sin(a);
  float c = cos(a);
  float x = c * v -s*2.;
  float y = s * v-c;
  float z = 0.05 * v;
  pos = vec3(x, y, z -s * u/3.);
}

float goop(float t) {
  return sin(t) - sin(t * 0.17) + tan((t * 0.13) + mouse.y -t) + sin(t * 0.73);
}

void main() {
  float circleId = floor(vertexId / NUM_POINTS_PER_CIRCLE);
  float pointId = mod(vertexId, NUM_POINTS_PER_CIRCLE);
// float sideId = floor(circleId / 2.);
// float side = mix(-1., 1., step(0.5, mod(circleId, 2.)));
  float numCircles = floor(vertexCount / NUM_POINTS_PER_CIRCLE);
  float cu = circleId / numCircles;
  vec3 pos;
  float inner = mix(0.03, 0.1, p1m1(sin(goop(circleId) - time / 3.1)));
  float start = fract(hash(circleId * 0.33) + sin(time * 0.83 + circleId) *2.1 *mouse.x);
  float end = start - 1.;//start + hash(sideId + 1.);
  vec2 uv;
  getCirclePoint(pointId, inner, start, end, pos, uv);

  float snd = texture(sound, vec2((cu + abs(uv.x/ 1.8 - 1.3)-7.) * 0.5, uv.y * 1.4)).r;

  vec3 offset = vec3(m1p1(hash(circleId)) * 1.5, m1p1(hash(circleId * 1.7)), m1p1(circleId / numCircles));
  offset.x += goop(circleId + time * mouse.x + 0.103) * 0.4;
  offset.y += goop(circleId + time * 0.13) * 0.31;
  vec3 aspect = vec3(4, resolution.y / resolution.x , mouse.y* 1.51);

  mat4 mat = ident();
  mat *= scale(aspect);
  mat *= trans(offset);
  mat *= uniformScale(mix(0.01, 0.2, hash(circleId)));
  gl_Position = vec4((mat * vec4(pos, 0.5)).xyz, 12.3 -mouse.y -(circleId + mouse.x));
  gl_PointSize = 5.;

  float hue = mix(1.51 *snd , 1.9 *mouse.x/ circleId-snd , fract(circleId * 12.79 - snd));
  float sat = 0.5 + snd;
  float val = 0. + snd ;
  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), (1. - uv.y) * pow(snd * 2.51, -snd*6.));
  v_color = vec4(2.1 *v_color.rgb * v_color.a, v_color.a /9.0);
}