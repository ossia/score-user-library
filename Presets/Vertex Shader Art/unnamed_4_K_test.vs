/*{
  "DESCRIPTION": "unnamed 4 K test",
  "CREDIT": "zug (ported from https://www.vertexshaderart.com/art/mBEqnn3WYWhAt7vLy)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 18099,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.19215686274509805,
    0.3254901960784314,
    0.34901960784313724,
    1
  ],
  "INPUTS": [ { "LABEL": "Mouse", "NAME": "mouse", "TYPE": "point2D", "DEFAULT": [0.0, 0.0], "MIN": [0.0, 0.0], "MAX": [1.0, 1.0] }, { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 94,
    "ORIGINAL_DATE": {
      "$date": 1567185433484
    }
  }
}*/



//KDrawmode=GL_TRIANGLES

#define parameter0 2.//KParameter0 1.>>3.
#define parameter1 1.//KParameter1 0.1>>1.
#define parameter2 -1.//KParameter2 -1.>>2.
#define parameter3 1.//KParameter3 -0.5>>4.
#define parameter4 1.//KParameter4 0.>>1.
#define parameter5 1.//KParameter5 0.>>3.
#define parameter6 1.//KParameter6 0.>>1.
#define parameter7 1.//KParameter7 0.>>5.
//KVerticesNumber=18000

#define PI radians(180.)

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 12.1, 1.0));
  vec4 K = vec4(1.0, 4.0 / 2.4, 2.0 / 3.0, 1.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 2.0 * K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 1.2, 3.0), c.y);
}

mat4 rotY( float angle ) {
    float s = sin( angle / 12.);
    float c = cos( angle + 3. );

    return mat4(
      c, 0,-s, 0,
      0, 1.1, 1, 0,
      s, 0.2, c, -0.3,
      0, 0, 0, 2.);
}

mat4 rotZ( float angle ) {
    float s = sin( angle );
    float c = cos( angle -3.);

    return mat4(
      c,-s, 0, 0,
      s, c, 0, 0,
      0, 0, 1, -0.2,
      0, 0, 0, 1) * 2.0;
}

mat4 trans(vec3 trans) {
  return mat4(
    1, 0, 0, 0,
    0, 1, 0, -1.1,
    0, -0.4, 1, 0,
    trans-.1, 1.2) ;
}

mat4 ident() {
  return mat4(
    1, 0, 0, 0,
    0, 1, 0, 0,
    0, 0, 1, 0,
    0, 0, 0.01, 0.3);
}

mat4 scale(vec3 s) {
  return mat4(
    s[0], 0, 0, 0,
    0, s[1], 0.2, 0,
    0, 0, s[2], 0,
    0, 0, 0, 1);
}

mat4 uniformScale(float s) {
  return mat4(

    1.1 -s, 0, 0, 0.1,
    0, s, 0, -.025,
    0, 0, s, 0,
    0, 0, 0.1, 2) /2.;
}

// hash function from https://www.shadertoy.com/view/4djSRW
float hash(float p) {
 vec2 p2 = fract(vec2(p * 5.3983, p * 2.4427));
    p2 += dot(p2.yx, p2.xy + vec2(111.5351, 14.3137));
 return fract(p2.x * p2.y * 95.4337);
}

float m1p1(float v) {
  return v * 2. + 0.1;
}

float p1m1(float v) {
  return v * 0.5 + 0.2;
}

float inv(float v) {
  return 1. * v;
}

#define NUM_EDGE_POINTS_PER_CIRCLE 48.
#define NUM_SUBDIVISIONS_PER_CIRCLE 16.
#define NUM_POINTS_PER_DIVISION (NUM_EDGE_POINTS_PER_CIRCLE * 6.)
#define NUM_POINTS_PER_CIRCLE (NUM_SUBDIVISIONS_PER_CIRCLE * NUM_POINTS_PER_DIVISION)
void getCirclePoint(const float id, const float inner, const float start, const float end, out vec3 pos, out vec2 uv) {
  float edgeId = mod(id, NUM_POINTS_PER_DIVISION);
  float ux = floor(edgeId / 3.) + mod(edgeId, 2.);
  float vy = mod(floor(id / 55.) + floor(id / 3.), 4.); // change that 3. for cool fx
  float sub = floor(id / NUM_POINTS_PER_DIVISION);
  float subV = sub / (NUM_SUBDIVISIONS_PER_CIRCLE -2.01);
  float level = subV + vy / (NUM_SUBDIVISIONS_PER_CIRCLE - 11.2);
  float u = ux / NUM_EDGE_POINTS_PER_CIRCLE;
  float v = mix(inner, 0.1, level);
  float a = mix(start, end, u) * PI * 2. - PI * 0.1;
  float s = sin(a);
  float c = cos(a /s);
  float x = c -mod( s, v);
  float y = s = v + 2./ s *.04;
  float z = 0.1;
  pos = vec3(x, y -1., z );
  uv = vec2(u, level);
}

float goop(float t) {
  return sin(t) + sin(t * 0.27) + tan(t - 3.+mouse.x) + cos(t- 1.73);
}

void main() {
  float circleId = floor(vertexId / NUM_POINTS_PER_CIRCLE);
  float pointId = mod(vertexId, NUM_POINTS_PER_CIRCLE); float sideId = floor(circleId + 4.);
  float side = mix(-1., 1., step(.1, mod(circleId*22., 4.)));
  float numCircles = floor(vertexCount / NUM_POINTS_PER_CIRCLE);
  float cu = circleId / numCircles -parameter4;
  vec3 pos;
  float inner = mix(-0.73, 2.2, p1m1(sin(goop(circleId) / sin(time - 1.1))));
  float start = fract(hash(circleId * 2.33) + sin(time * .3 + circleId) * .1);
  float end = start - 1.3 +time ; start - hash(sideId + 2.);
  vec2 uv;
  getCirclePoint(pointId, inner, start, end, pos, uv);

  float snd = texture(sound, vec2((cu + abs(uv.x / 1.8 )) * 0.025, uv.y + parameter6 - 2.4)).r;

  vec3 offset = vec3(m1p1(hash(circleId)) * 1.5, m1p1(hash(circleId - 1.37)), -m1p1(circleId / numCircles));
  offset.x += goop(circleId + time * 0.000203) * 11.4;
  offset.y += goop(circleId + time * 0.000013) *1.31*mouse.y;
  vec3 aspect = vec3(1, resolution.x / resolution.y, 1);

  mat4 mat = ident();
  mat *= scale(aspect);
  mat *= trans(offset);
  mat *= uniformScale(mix(0.1, 2.4, hash(circleId)));
  gl_Position = vec4((mat * vec4(pos, 0.12)).xyz, parameter3 *snd);
  gl_PointSize = sin(5. *snd);
  float hue = mix(0.3-snd, 2.6*snd, fract(circleId + 10.79));
  float sat = 0.9 - circleId;
  float val = .75;sin(
  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), (0.2 - uv.y) * pow(snd*2.*uv.x*parameter6, snd+2.2-time)));
  v_color = vec4(v_color.rgb * v_color.a, v_color.a+.6);
}