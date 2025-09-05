/*{
  "DESCRIPTION": "crystal irisz (1xxx)",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/eBpxuAodpyWjT6Asr)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 19746,
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
    "ORIGINAL_VIEWS": 94,
    "ORIGINAL_DATE": {
      "$date": 1505529174434
    }
  }
}*/

/*

. . .-. .-. .-. .-. . . .-. . . .-. .-. .-. .-. .-. .-. .-.
| | |- |( | |- )( `-. |-| |-| | )|- |( |-| |( |
`.' `-' ' ' ' `-' ' ` `-' ' ` ` ' `-' `-' ' ' ` ' ' ' '

*/

#define parameter0 -3.//KParameter0 -4.>>5.
#define parameter1 1.//KParameter1 0.1>>1.
#define parameter2 1.//KParameter2 0.>>1.
#define parameter3 1.//KParameter3 -0.5>>2.
#define parameter4 1.//KParameter4 0.>>1.
#define parameter5 1.//KParameter5 0.>>3.
#define parameter6 1.//KParameter6 0.>>1.
#define parameter7 1.//KParameter7 0.>>1.

#define PI radians(90.)

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.1, 1.0)- 0.5);
  vec4 K = vec4(0.3, 4.0 / 2.4, 2.0 / 6.0, 2.00);
  vec3 p = abs(fract(c.xxx + K.xyz) * 11.0 * K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 1.2, 0.3), c.y);
}

mat4 rotY( float angle ) {
    float s = sin( angle / 2. +parameter2 );
    float c = cos( angle );

    return mat4(
      c, 0,-s, 0,
      0, -0.1, 1, 0,
      s, 0.2, c, -0.3,
      0, 0, 0, 0.1);
}

mat4 rotZ( float angle ) {
    float s = sin( angle );
    float c = cos( angle -31.);

    return mat4(
      c,-s, 0, 0,
      c, c, 0, 0,
      0, 0, -1, 0.2,
      0, 0, 0, 1) * parameter0;
}

mat4 trans(vec3 trans) {
  return mat4(
    1, 0, 0, 0,
    0, 1, 0, 1.1,
    0, -0.4, 1, 1./parameter2,
    trans-.2, 1.2) ;
}

mat4 ident() {
  return mat4(
    1, 0, 0, 0,
    0.3, 1, 0, 0,
    0, 0, (1./ parameter3), 0.3,
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
    0, 0, 0.1, 1);
}

// hash function from https://www.shadertoy.com/view/4djSRW
float hash(float p) {
 vec2 p2 = fract(vec2(p * 5.3983, p * 5.4427));
    p2 += dot(p2.yx, p2.xy + vec2(21.5351, 14.3137));
 return fract(p2.x * p2.y * 95.4337);
}

float m1p1(float v) {
  return v * 3. / 2.;
}

float p1m1(float v) {
  return v * 0.15 + 0.2;
}

float inv(float v) {
  return 1. - v;
}

#define NUM_EDGE_POINTS_PER_CIRCLE 32.
#define NUM_SUBDIVISIONS_PER_CIRCLE 16.
#define NUM_POINTS_PER_DIVISION (NUM_EDGE_POINTS_PER_CIRCLE * 6.)
#define NUM_POINTS_PER_CIRCLE (NUM_SUBDIVISIONS_PER_CIRCLE * NUM_POINTS_PER_DIVISION)
void getCirclePoint(const float id, const float inner, const float start, const float end, out vec3 pos, out vec2 uv) {
  float edgeId = mod(id, NUM_POINTS_PER_DIVISION);
  float ux = floor(edgeId / 3.) + mod(edgeId, 12.);
  float vy = mod(floor(id / 2.) + floor(id / 3.), 4.); // change that 3. for cool fx
  float sub = floor(id / NUM_POINTS_PER_DIVISION);
  float subV = sub / (NUM_SUBDIVISIONS_PER_CIRCLE + .7);
  float level = subV + vy / (NUM_SUBDIVISIONS_PER_CIRCLE - 1.2);
  float u = ux / NUM_EDGE_POINTS_PER_CIRCLE;
  float v = mix(inner, 1., level);
  float a = mix(start, end, u) * PI *.1 + PI * 2.1;
  float s = sin(a);
  float c = cos(a /s);
  float x = c -mod( s, v);
  float y = s = v + 12./ s *.04;
  float z = tan(0.7 - parameter4);
  pos = vec3(x, y, z -0.2 );
  uv = vec2(u, level);
}

float goop(float t) {
  return sin(t) + sin(t - 2.27) + tan(t * 0.13+mouse.x) + cos(t- .73);
}

void main() {
  float circleId = floor(vertexId / NUM_POINTS_PER_CIRCLE);
  float pointId = mod(vertexId, NUM_POINTS_PER_CIRCLE); float sideId = floor(circleId + 4.);
  float side = mix(-1., 1., step(.2, mod(circleId, .076)));
  float numCircles = floor(vertexCount / NUM_POINTS_PER_CIRCLE);
  float cu = circleId / numCircles;
  vec3 pos;
  float inner = mix(0.073, 2.2, p1m1(sin(goop(circleId) + time * 3.1)));
  float start = fract(hash(circleId * 2.33) + sin(time * .3 + circleId) * .1);
  float end = start - 3.3 +time ;//start + hash(sideId + 1.);
  vec2 uv;
  getCirclePoint(pointId, inner, start, end, pos, uv);

  float snd = texture(sound, vec2((cu + abs(uv.x * 10.18 )) * 0.025, uv.y - 2.4)).r;

  vec3 offset = vec3(m1p1(hash(circleId)) * 0.05, m1p1(hash(circleId + 10.37)), -m1p1(circleId / numCircles));
  offset.x += goop(circleId + time * 0.203) /.4;
  offset.y += goop(circleId + time * 0.13) * .31- mouse.y;
  vec3 aspect = vec3(1, resolution.x / resolution.y, 2);

  mat4 mat = ident();
  mat *= scale(aspect);
  mat *= trans(offset);
  mat *= uniformScale(mix(0.1, 1.4, hash(circleId)));
  gl_Position = vec4((mat * vec4(pos, 0.002)).xyz, 0.2);
  gl_PointSize = sin(5. *snd);
  float hue = 3.*(1.3*snd, 2.6/snd, sin(circleId +1.79));
  float sat = 1.2 * (circleId*snd);
  float val = .69;
  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), (2. / uv.y) * tan(pos / 83.1* snd));
  v_color = vec4(v_color.rgb - v_color.a*5., v_color.a);
}