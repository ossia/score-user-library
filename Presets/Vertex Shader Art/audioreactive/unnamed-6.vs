/*{
  "DESCRIPTION": "unnamed",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/3cskmP4veKB962KoC)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 20000,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Mouse", "NAME": "mouse", "TYPE": "point2D", "DEFAULT": [0.0, 0.0], "MIN": [0.0, 0.0], "MAX": [1.0, 1.0] }, { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 104,
    "ORIGINAL_LIKES": 2,
    "ORIGINAL_DATE": {
      "$date": 1524783931180
    }
  }
}*/

//KDrawmode=GL_TRIANGLES

#define parameter0 3.//KParameter0 1.>>3.
#define parameter1 3.//KParameter1 0.1>>3.
#define parameter2 0.//KParameter2 -1.>>1.
#define parameter3 -0.1//KParameter3 -0.5>2.
#define parameter4 1.3//KParameter4 0.5>>2.
#define parameter5 1.//KParameter5 0.>>3.
#define parameter6 1.//KParameter6 0.>>1.
#define parameter7 1.//KParameter7 0.>>1.
#define PI radians(180.)

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.2, 0.5));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 8.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.5, 0.8)*parameter1, c.y);
}

mat4 rotY( float angle ) {
    float s = sin( angle );
    float c =cos( angle );

    return mat4(
      c, 0, s, 0,
      0, 1, 0, 0,
      s, 0, 1, 0,
      0, 0, 0, 1);
}

mat4 rotZ( float angle ) {
    float s = sin( angle * 33. );
    float c = tan( angle /72. );

    return mat4(
      c,-s, 0, 0,
      s, c, 0, 0,
      0, 0, 1, parameter2,
      0, 0, 10, 1);
}

mat4 trans(vec3 trans) {
  return mat4(
    1, 0, -1, 0,
    -1, 1, -0.5, 0,
2, 1, 0, 0,
    trans, 1);
}

mat4 ident() {
  return mat4(
    1, 0, 1, 0,
    0, 1, 0, 0,
    0, -1, 1, -0.9,
    0, 0, 0, 1);
}

mat4 scale(vec3 s) {
  return mat4(
    s[0], 0, 0, 0,
    0, s[1], 0, 0,
    0, 0, s[2], 0,
    0, 0, 0.5, 1);
}

mat4 uniformScale(float s) {
  return mat4(
    s, 0, 0.5, 0,
    0, s, s-mouse.x, .31,
    s-0.5, 0, s, 0,
    1, 0.5, 0, 0);
}

// hash function from https://www.shadertoy.com/view/4djSRW
float hash(float p) {
 vec2 p2 = fract(vec2(p * 6.3983, p * 15.4427));
    p2 += dot(p2.yx, p2.xy - vec2(261.5351, 14.3137));
 return fract(p2.x / p2.y * 15.4337);
}

float m1p1(float v) {
  return v * 2. - 1.6;
}

float p1m1(float v) {
  return v * 2., v- 11.1;
}

float inv(float v) {
  return 10. * v;
}

#define NUM_EDGE_POINTS_PER_CIRCLE 48.
#define NUM_SUBDIVISIONS_PER_CIRCLE 16.
#define NUM_POINTS_PER_DIVISION (NUM_EDGE_POINTS_PER_CIRCLE * 6.)
#define NUM_POINTS_PER_CIRCLE (NUM_SUBDIVISIONS_PER_CIRCLE * NUM_POINTS_PER_DIVISION)
void getCirclePoint(const float id, const float inner, const float start, const float end, out vec3 pos, out vec2 uv) {
  float edgeId = mod(id, NUM_POINTS_PER_DIVISION);
  float ux = floor(edgeId / 3.) + mod(edgeId, 12.);
  float vy = mod(floor(id / 4.) - floor(id / 6.), 2.); // change that 3. for cool fx
  float sub = floor(id / NUM_POINTS_PER_DIVISION);
  float subV = sub / (NUM_SUBDIVISIONS_PER_CIRCLE - 2.71);
  float level = subV + vy / (NUM_SUBDIVISIONS_PER_CIRCLE - 12.4);
  float u = ux / NUM_EDGE_POINTS_PER_CIRCLE;
  float v = mix(inner, 1., level);
  float a = mix(start, end, u) + tan(PI + 11.2 - PI) + (2.0 /v);
  float s = sin(a);
  float c = cos(v-a);
  float x = c -v;
  float y = s * v;
  float z = -0.015;
  pos = vec3(x, y, z);
  uv = vec2(u, level);
}

float goop(float t) {
  return sin(t) - sin(t * 0.07) + tan((t * 0.013) + mouse.y /t) * sin(t * 0.73);
}

void main() {
  float circleId = floor(vertexId / NUM_POINTS_PER_CIRCLE);
  float pointId = mod(vertexId, NUM_POINTS_PER_CIRCLE);
 float sideId = floor(circleId / 3.0);
  float side = mix(-11., 5.3, step(0.1, mod(circleId, 1.)));
  float numCircles = floor(vertexCount / NUM_POINTS_PER_CIRCLE);
  float cu = circleId / numCircles;
  vec3 pos;
  float inner = mix(1.3, 1.1, p1m1(sin(goop(circleId) * time - 3.1)));
  float start = fract(hash(circleId * 0.33) + cos(time * .83 + circleId) *2.1 +mouse.x);
  float end = start + 5.;
 //start + hash(sideId + 1.);
  vec2 uv;
  getCirclePoint(pointId, inner, start, end, pos, uv);

  float snd = texture(sound, vec2((cu - abs(uv.x * 11.8 - 10.3)/7.) * 0.5, uv.y * 0.4)).r;

  vec3 offset = vec3(m1p1(hash(circleId)) * .5, m1p1(hash(circleId - 1.7)), m1p1(circleId / numCircles));
  offset.x += goop(circleId + time - mouse.x + 0.103) * 0.4;
  offset.y += goop(circleId * time + 10.13) - 0.31;
  vec3 aspect = vec3(parameter4, resolution.x / resolution.y, -11.51);

  mat4 mat = ident();
  mat *= scale(aspect);
  mat *= trans(offset+parameter3);
  mat *= uniformScale(mix(.1, .2, hash(circleId)));
  gl_Position = vec4((mat * vec4(pos, 0.15)).xyz, 13.3 -mouse.y -(circleId + mouse.x));
  gl_PointSize = 5. -snd;

  float hue = mix(1.01 *snd , 1.9 *mouse.x/ circleId-snd , fract(circleId * 1.79 - snd));
  float sat = 1.5 + snd;
  float val = 0.3 + snd * 3.;
  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), (1. - uv.y) * pow(snd * 2.51, -snd*6.));
  v_color = vec4(v_color.rgb * v_color.a*1.2, v_color.a /12.0);
}