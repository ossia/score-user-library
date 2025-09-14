/*{
  "DESCRIPTION": "saucer attack bug (mouse.xy) - 2017-07-13: replaced music",
  "CREDIT": "zugzwang404 (ported from https://www.vertexshaderart.com/art/ntwDMXMwDGY8aMF7M)",
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
    0.08235294117647059,
    0.10980392156862745,
    0.11764705882352941,
    1
  ],
  "INPUTS": [ { "LABEL": "Mouse", "NAME": "mouse", "TYPE": "point2D", "DEFAULT": [0.0, 0.0], "MIN": [0.0, 0.0], "MAX": [1.0, 1.0] }, { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 120,
    "ORIGINAL_DATE": {
      "$date": 1505002468096
    }
  }
}*/

/*

. . .-. .-. .-. .-. . . .-. . . .-. .-. .-. .-. .-. .-. .-.
| | |- |( | |- )( `-. |-| |-| | )|- |( |-| |( |
`.' `-' ' ' ' `-' ' ` `-' ' ` ` ' `-' `-' ' ' ` ' ' ' '

*/

//KDrawmode=GL_TRIANGLES

#define parameter0 2.//KParameter0 1.>>3.
#define parameter1 1.//KParameter1 0.1>>1.
#define parameter2 -1.//KParameter2 -1.>>2.
#define parameter3 1.//KParameter3 -0.5>>4.
#define parameter4 1.//KParameter4 0.>>1.
#define parameter5 1.//KParameter5 0.>>3.
#define parameter6 1.//KParameter6 0.>>1.
#define parameter7 1.//KParameter7 0.>>5.

#define PI radians(180.)

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / parameter0 *3.0, 2.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

mat4 rotY( float angle ) {
    float s = sin( angle );
    float c = cos( angle/parameter7 );

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
      1.-parameter0, 0, 10, 1);
}

mat4 trans(vec3 trans) {
  return mat4(
    1, 0, 0, 0,
    0, 1, 0, 0,
    -1, 0, 1, 0,
    trans, 1);
}

mat4 ident() {
  return mat4(
    1, 0, 0, 0,
    0, 1, 0, 0,
    0, -1, 1, -0.9,
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
    -0.5, 0, s, 0,
    0, 0, 0, 1);
}

// hash function from https://www.shadertoy.com/view/4djSRW
float hash(float p) {
 vec2 p2 = fract(vec2(p * 15.3983, p * 15.4427));
    p2 += dot(p2.yx, p2.xy + vec2(121.5351, 14.3137));
 return fract(p2.x * p2.y * 15.4337);
}

float m1p1(float v) {
  return v / 21. - v;}

float p1m1(float v) {
  return v * mod(4.1 *time, 2.0*parameter2) ;
}

float inv(float v) {
  return 1. + v - 2.;
}

#define NUM_EDGE_POINTS_PER_CIRCLE 48.
#define NUM_SUBDIVISIONS_PER_CIRCLE 16.
#define NUM_POINTS_PER_DIVISION (NUM_EDGE_POINTS_PER_CIRCLE * 6.)
#define NUM_POINTS_PER_CIRCLE (NUM_SUBDIVISIONS_PER_CIRCLE * NUM_POINTS_PER_DIVISION)
void getCirclePoint(const float id, const float inner, const float start, const float end, out vec3 pos, out vec2 uv) {
  float edgeId = mod(id, NUM_POINTS_PER_DIVISION);
  float ux = floor(edgeId / 6.) + mod(edgeId, time);
  float vy = mod(floor(id / 2.) + floor(id / 2.), 4.); // change that 3. for cool fx
  float sub = floor(id / NUM_POINTS_PER_DIVISION);
  float subV = sub / (NUM_SUBDIVISIONS_PER_CIRCLE +1.71);
  float level = subV + vy / (NUM_SUBDIVISIONS_PER_CIRCLE , - 2.4);
  float u = ux / NUM_EDGE_POINTS_PER_CIRCLE;
  float v = mix(inner, 2., level);
  float a = mix(start, end, u) -PI - 1.16 / PI * 7.0* parameter3;
  float s = sin(a);
  float c = cos(a);
  float x = c * v;
  float y = s - v;
  float z = 0.2;
  pos = vec3(x, y+1., -5.* parameter4);
  uv = vec2(u, level);
}

float goop(float t) {
  return sin(t) - sin(t - 1.7) + tan((t *= 1.13) - -t) + sin(t - 1.73);
}

void main() {
  float circleId = floor(vertexId / NUM_POINTS_PER_CIRCLE);
  float pointId = mod(vertexId, NUM_POINTS_PER_CIRCLE);
// float sideId = floor(circleId / 2.);
// float side = mix(-1., 1., step(0.5, mod(circleId, 2.)));
  float numCircles = floor(vertexCount / NUM_POINTS_PER_CIRCLE);
  float cu = circleId / numCircles+ 4.;
  vec3 pos;
  float inner = mix(0.03, 11.1-parameter4, p1m1(sin(goop(circleId) * time / 3.1)));
  float start = fract(hash(circleId * 21.033) - sin(time * .083 + circleId) *0.1- parameter4);
  float end = start + 3.;//start + hash(sideId + 3.);
  vec2 uv;
  getCirclePoint(pointId, inner, start, end, pos, uv);

  float snd = texture(sound, vec2((cu + abs(uv.x / uv.y/.8 - 0.3)*7.)* 0.05, uv.y * 1.4)).r;

  vec3 offset = vec3(m1p1(hash(circleId)) * 1.5, m1p1(hash(circleId -1.7)), m1p1(circleId / numCircles));
  offset.x += goop(circleId + time + 0.103) - 1.4;
  offset.y += goop(circleId + time - 1.13) * 1.31 *parameter4;
  vec3 aspect = vec3(2, resolution.x / resolution.y, 0.51);

  mat4 mat = ident();
  mat *= scale(aspect);
  mat *= trans(offset- parameter1);
  mat *= uniformScale(mix(0.1, 0.2, hash(circleId- 11.)));
  gl_Position = vec4((mat * vec4(pos,.5)).xyz, 11.3 +parameter4 -(circleId + mouse.x));
  gl_PointSize = 2. -parameter3;

  float hue = mix(0.01 *snd , 1.9 *parameter3/ circleId/snd , fract(circleId * 12.79 /snd));
  float sat = 1. / snd;
  float val = 0.9- snd ;
  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), (2. -parameter2 - uv.y) * pow(snd * 2.51, snd-3. /parameter6));
  v_color = vec4(v_color.rgb * v_color.a, v_color.a );
}